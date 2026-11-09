#include "wayland_input.h"
#include "linux_key_map.h"

#include <gdk/gdkwayland.h>
#include <gio/gunixfdlist.h>
#include <gio/gunixoutputstream.h>
#include <functional>
#include <memory>
#include <set>
#include <string>
#include <vector>
#include <utility>

namespace {
constexpr const char* kDesktop = "org.freedesktop.portal.Desktop";
constexpr const char* kPath = "/org/freedesktop/portal/desktop";
constexpr const char* kRemote = "org.freedesktop.portal.RemoteDesktop";
constexpr const char* kClipboard = "org.freedesktop.portal.Clipboard";
GVariant* options() { return g_variant_new_array(G_VARIANT_TYPE("{sv}"), nullptr, 0); }
FlValue* arg(FlValue* args, const char* key) {
  return args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP
      ? fl_value_lookup_string(args, key) : nullptr;
}
int integer(FlValue* args, const char* key) {
  auto* v = arg(args, key);
  return v && fl_value_get_type(v) == FL_VALUE_TYPE_INT ? fl_value_get_int(v) : 0;
}
std::string string(FlValue* args, const char* key) {
  auto* v = arg(args, key);
  return v && fl_value_get_type(v) == FL_VALUE_TYPE_STRING ? fl_value_get_string(v) : "";
}

struct Event {
  const char* method;
  GVariant* parameters;
  bool release;
  int key;
  Event(const char* name, GVariant* args, bool up = false, int code = 0)
      : method(name), parameters(g_variant_ref_sink(args)), release(up), key(code) {}
  Event(Event&& other) noexcept : method(other.method), parameters(other.parameters), release(other.release), key(other.key) {
    other.parameters = nullptr;
  }
  ~Event() { if (parameters) g_variant_unref(parameters); }
};

class PortalInput {
 public:
  using Done = std::function<void()>;
  using InputDone = std::function<void(int, const std::string&)>;
  GDBusConnection* bus = nullptr;
  bool ready = false;
  bool busy = false;
  bool clipboard = false;
  std::string message = "Wayland：请点击授权，允许远程键盘和鼠标控制";
  std::string session;
  guint generation = 0;

  FlValue* status() const {
    auto* result = fl_value_new_map();
    fl_value_set_string_take(result, "backend", fl_value_new_string("wayland"));
    fl_value_set_string_take(result, "ready", fl_value_new_bool(ready));
    fl_value_set_string_take(result, "busy", fl_value_new_bool(busy));
    fl_value_set_string_take(result, "clipboard", fl_value_new_bool(clipboard));
    fl_value_set_string_take(result, "message", fl_value_new_string(message.c_str()));
    return result;
  }

  void authorize(Done done) {
    if (busy || in_flight) { done(); return; }
    reset("Wayland：正在请求桌面授权…");
    busy = true;
    authorization_done = std::move(done);
    deadline = g_timeout_add_seconds(120, [](gpointer p) -> gboolean {
      auto* self = static_cast<PortalInput*>(p);
      self->deadline = 0;
      self->reset("Wayland 授权超时；请重试");
      return G_SOURCE_REMOVE;
    }, this);
    auto* context = new Context{this, generation, 0};
    g_bus_get(G_BUS_TYPE_SESSION, nullptr, [](GObject*, GAsyncResult* r, gpointer p) {
      std::unique_ptr<Context> c(static_cast<Context*>(p));
      g_autoptr(GError) error = nullptr;
      GDBusConnection* connection = g_bus_get_finish(r, &error);
      if (c->generation != c->self->generation) {
        if (connection) g_object_unref(connection);
        return;
      }
      if (!connection) { c->self->reset("无法连接桌面 Session D-Bus"); return; }
      auto* self = c->self;
      if (!self->bus) {
        self->bus = connection;
        self->watch = g_bus_watch_name_on_connection(connection, kDesktop, G_BUS_NAME_WATCHER_FLAGS_NONE,
          nullptr, [](GDBusConnection*, const gchar*, gpointer data) {
            auto* self = static_cast<PortalInput*>(data);
            if (self->ready) self->reset("桌面 portal 已退出；请重新授权");
          }, self, nullptr);
        self->transfer_subscription = g_dbus_connection_signal_subscribe(connection, kDesktop,
            kClipboard, "SelectionTransfer", kPath, nullptr, G_DBUS_SIGNAL_FLAGS_NONE,
            clipboard_transfer, self, nullptr);
      } else {
        g_object_unref(connection);
      }
      self->request(0);
    }, context);
  }

  void reset(const std::string& reason) {
    ++generation;
    ready = false;
    busy = false;
    clipboard = false;
    message = reason;
    clipboard_text.clear();
    vertical = horizontal = 0;
    if (deadline) { g_source_remove(deadline); deadline = 0; }
    if (bus && response_subscription) {
      g_dbus_connection_signal_unsubscribe(bus, response_subscription);
      response_subscription = 0;
    }
    if (bus && closed_subscription) {
      g_dbus_connection_signal_unsubscribe(bus, closed_subscription);
      closed_subscription = 0;
    }
    if (bus && !request_path.empty()) close_object(request_path, "org.freedesktop.portal.Request");
    request_path.clear();
    if (bus && !session.empty()) close_object(session, "org.freedesktop.portal.Session");
    session.clear();
    auto done = std::move(authorization_done);
    authorization_done = nullptr;
    if (done) done();
  }

  void inject(const std::string& method, FlValue* args, InputDone done) {
    if (!ready) { done(0, message); return; }
    if (in_flight) { done(0, "输入正在执行，请稍后重试"); return; }
    auto* command = new Command{this, generation, session, {}, 0, 0, "", std::move(done), {}};
    if (method == "keyStroke") {
      int code = linux_key_code(string(args, "key"));
      int bits = integer(args, "modifiers");
      if (!code || bits < 0 || bits > 255) {
        command->done(0, "无效的语义按键或修饰位"); delete command; return;
      }
      append_stroke(command, code, bits);
    } else if (method == "text") {
      std::string text = string(args, "text");
      if (text.empty() || text.size() > 32768 || !g_utf8_validate(text.c_str(), text.size(), nullptr)) {
        command->done(0, "文本为空、过长或不是有效 UTF-8"); delete command; return;
      }
      if (!clipboard) {
        command->done(0, "桌面未授予 Clipboard portal 权限；中文文本粘贴不可用，请重新授权");
        delete command; return;
      }
      clipboard_text = std::move(text);
      GVariantBuilder b;
      g_variant_builder_init(&b, G_VARIANT_TYPE_VARDICT);
      const gchar* types[] = {"text/plain;charset=utf-8", "text/plain", "UTF8_STRING", nullptr};
      g_variant_builder_add(&b, "{sv}", "mime_types", g_variant_new_strv(types, -1));
      command->events.emplace_back("SetSelection", g_variant_new("(o@a{sv})", session.c_str(), g_variant_builder_end(&b)));
      // Clipboard portal owns CLIPBOARD, not PRIMARY. Ctrl+V is the default;
      // the status page can opt into Ctrl+Shift+V for terminal applications.
      append_stroke(command, KEY_V, 1 | (integer(args, "terminalPaste") ? 16 : 0));
    } else if (method == "pointer") {
      int dx = integer(args, "deltaX"), dy = integer(args, "deltaY");
      if (dx || dy) command->events.emplace_back("NotifyPointerMotion",
          g_variant_new("(o@a{sv}dd)", session.c_str(), options(), double(dx), double(dy)));
      auto name = string(args, "button");
      int button = name == "left" ? BTN_LEFT : name == "middle" ? BTN_MIDDLE : name == "right" ? BTN_RIGHT : 0;
      if (button) {
        auto* value = arg(args, "buttonDown");
        bool down = value && fl_value_get_type(value) == FL_VALUE_TYPE_BOOL && fl_value_get_bool(value);
        command->events.emplace_back("NotifyPointerButton",
            g_variant_new("(o@a{sv}iu)", session.c_str(), options(), button, guint(down)), !down);
      }
      // XDG discrete axes: vertical positive is down, horizontal positive right.
      vertical += integer(args, "wheelDelta");
      horizontal += integer(args, "horizontalWheelDelta");
      auto wheel = [&](int& remainder, guint axis, int direction) {
        int steps = remainder / 120;
        remainder %= 120;
        if (steps) command->events.emplace_back("NotifyPointerAxisDiscrete",
            g_variant_new("(o@a{sv}ui)", session.c_str(), options(), axis, steps * direction));
      };
      wheel(vertical, 0, -1);
      wheel(horizontal, 1, 1);
    } else {
      command->done(0, "未知 Wayland 输入命令"); delete command; return;
    }
    in_flight = true;
    next_event(command);
  }

 private:
  struct Context { PortalInput* self; guint generation; int step; };
  struct Command {
    PortalInput* self;
    guint generation;
    std::string session;
    std::vector<Event> events;
    size_t next;
    int count;
    std::string error;
    InputDone done;
    std::set<int> attempted_keys;
  };
  Done authorization_done;
  guint response_subscription = 0, closed_subscription = 0, transfer_subscription = 0;
  guint deadline = 0, watch = 0;
  guint token = 0;
  int phase = 0;
  bool in_flight = false;
  int vertical = 0, horizontal = 0;
  std::string request_path, clipboard_text;

  void close_object(const std::string& path, const char* interface) {
    g_dbus_connection_call(bus, kDesktop, path.c_str(), interface, "Close", nullptr,
        nullptr, G_DBUS_CALL_FLAGS_NONE, 3000, nullptr, nullptr, nullptr);
  }

  void request(int step) {
    phase = step;
    std::string suffix = "netkeyboard_" + std::to_string(++token);
    std::string sender = g_dbus_connection_get_unique_name(bus) + 1;
    for (auto& c : sender) if (c == '.') c = '_';
    request_path = "/org/freedesktop/portal/desktop/request/" + sender + "/" + suffix;
    response_subscription = g_dbus_connection_signal_subscribe(bus, kDesktop,
        "org.freedesktop.portal.Request", "Response", request_path.c_str(), nullptr,
        G_DBUS_SIGNAL_FLAGS_NONE, response, new Context{this, generation, step},
        [](gpointer p) { delete static_cast<Context*>(p); });
    GVariantBuilder b;
    g_variant_builder_init(&b, G_VARIANT_TYPE_VARDICT);
    g_variant_builder_add(&b, "{sv}", "handle_token", g_variant_new_string(suffix.c_str()));
    if (step == 0) {
      std::string session_token = suffix + "_session";
      g_variant_builder_add(&b, "{sv}", "session_handle_token", g_variant_new_string(session_token.c_str()));
    } else if (step == 1) {
      g_variant_builder_add(&b, "{sv}", "types", g_variant_new_uint32(3));
    }
    GVariant* dict = g_variant_builder_end(&b);
    GVariant* parameters = step == 0 ? g_variant_new("(@a{sv})", dict)
        : step == 1 ? g_variant_new("(o@a{sv})", session.c_str(), dict)
        : g_variant_new("(os@a{sv})", session.c_str(), "", dict);
    g_dbus_connection_call(bus, kDesktop, kPath, kRemote,
        step == 0 ? "CreateSession" : step == 1 ? "SelectDevices" : "Start", parameters,
        G_VARIANT_TYPE("(o)"), G_DBUS_CALL_FLAGS_NONE, 10000, nullptr,
        [](GObject* object, GAsyncResult* r, gpointer p) {
          std::unique_ptr<Context> c(static_cast<Context*>(p));
          g_autoptr(GError) error = nullptr;
          g_autoptr(GVariant) reply = g_dbus_connection_call_finish(G_DBUS_CONNECTION(object), r, &error);
          if (c->generation != c->self->generation || c->step != c->self->phase) return;
          if (!reply) c->self->reset(std::string("RemoteDesktop portal 调用失败：") +
              (error ? error->message : "未知错误"));
        }, new Context{this, generation, step});
  }

  static void response(GDBusConnection*, const gchar*, const gchar*, const gchar*,
                       const gchar*, GVariant* parameters, gpointer p) {
    Context context = *static_cast<Context*>(p);
    auto* self = context.self;
    if (context.generation != self->generation || context.step != self->phase) return;
    guint code;
    g_autoptr(GVariant) results = nullptr;
    g_variant_get(parameters, "(u@a{sv})", &code, &results);
    g_dbus_connection_signal_unsubscribe(self->bus, self->response_subscription);
    self->response_subscription = 0;
    self->request_path.clear();
    if (code != 0) {
      self->reset(code == 1 ? "Wayland 授权已取消；可重新授权" : "桌面拒绝远程输入授权；请检查 portal 后端");
      return;
    }
    if (context.step == 0) {
      const gchar* handle = nullptr;
      if (!g_variant_lookup(results, "session_handle", "&s", &handle) || !g_variant_is_object_path(handle)) {
        self->reset("portal 返回无效会话"); return;
      }
      self->session = handle;
      self->closed_subscription = g_dbus_connection_signal_subscribe(self->bus, kDesktop,
          "org.freedesktop.portal.Session", "Closed", handle, nullptr, G_DBUS_SIGNAL_FLAGS_NONE,
          [](GDBusConnection*, const gchar*, const gchar*, const gchar*, const gchar*, GVariant*, gpointer p) {
            static_cast<PortalInput*>(p)->reset("Wayland 控制授权已撤销；请重新授权");
          }, self, nullptr);
      self->request(1);
    } else if (context.step == 1) {
      self->phase = 2;
      g_dbus_connection_call(self->bus, kDesktop, kPath, kClipboard, "RequestClipboard",
          g_variant_new("(o@a{sv})", self->session.c_str(), options()), nullptr,
          G_DBUS_CALL_FLAGS_NONE, 10000, nullptr,
          [](GObject* object, GAsyncResult* r, gpointer p) {
            std::unique_ptr<Context> c(static_cast<Context*>(p));
            g_autoptr(GError) error = nullptr;
            g_autoptr(GVariant) result = g_dbus_connection_call_finish(G_DBUS_CONNECTION(object), r, &error);
            if (c->generation != c->self->generation) return;
            // Clipboard is optional: older compositors can still grant keys/pointer.
            c->self->request(3);
          }, new Context{self, self->generation, 2});
    } else {
      guint devices = 0;
      g_variant_lookup(results, "devices", "u", &devices);
      if ((devices & 3) != 3) { self->reset("需要同时授权键盘和鼠标；请重新授权"); return; }
      gboolean clipboard = false;
      g_variant_lookup(results, "clipboard_enabled", "b", &clipboard);
      self->clipboard = clipboard;
      self->ready = true;
      self->busy = false;
      self->message = clipboard ? "Wayland 键盘、鼠标与文本粘贴已授权"
          : "Wayland 键盘与鼠标已授权；桌面不支持或未授权文本剪贴板";
      if (self->deadline) { g_source_remove(self->deadline); self->deadline = 0; }
      auto done = std::move(self->authorization_done);
      self->authorization_done = nullptr;
      if (done) done();
    }
  }

  static void append_key(Command* c, int key, bool down) {
    c->events.emplace_back("NotifyKeyboardKeycode",
        g_variant_new("(o@a{sv}iu)", c->session.c_str(), options(), key, guint(down)), !down, key);
  }
  static void append_stroke(Command* c, int key, int bits) {
    const auto& codes = linux_modifier_codes();
    for (size_t i = 0; i < codes.size(); ++i) if (bits & (1 << i)) append_key(c, codes[i], true);
    append_key(c, key, true);
    append_key(c, key, false);
    for (int i = 7; i >= 0; --i) if (bits & (1 << i)) append_key(c, codes[i], false);
  }
  static void next_event(Command* c) {
    if (c->generation != c->self->generation) {
      c->error = "Wayland 授权会话已结束；命令不会重放";
      c->next = c->events.size();
    }
    // On transport failure send only remaining releases, then revoke the session.
    while (c->next < c->events.size() && !c->error.empty()) {
      auto& e = c->events[c->next];
      if (e.release && (!e.key || c->attempted_keys.count(e.key))) break;
      ++c->next;
    }
    if (c->next == c->events.size()) {
      auto* self = c->self;
      self->in_flight = false;
      if (!c->error.empty() && c->generation == self->generation)
        self->reset("Wayland 输入失败；会话已关闭，请重新授权");
      c->done(c->count, c->error);
      delete c;
      return;
    }
    auto& e = c->events[c->next++];
    if (e.key && !e.release) c->attempted_keys.insert(e.key);
    g_dbus_connection_call(c->self->bus, kDesktop, kPath,
        std::string(e.method) == "SetSelection" ? kClipboard : kRemote,
        e.method, e.parameters, G_VARIANT_TYPE_UNIT, G_DBUS_CALL_FLAGS_NONE, 3000,
        nullptr, [](GObject* object, GAsyncResult* r, gpointer p) {
          auto* c = static_cast<Command*>(p);
          g_autoptr(GError) error = nullptr;
          g_autoptr(GVariant) result = g_dbus_connection_call_finish(G_DBUS_CONNECTION(object), r, &error);
          if (!result) c->error = "桌面拒绝输入事件或 portal 连接中断";
          else if (std::string(c->events[c->next - 1].method) != "SetSelection") ++c->count;
          next_event(c);
        }, c);
  }

  struct Transfer {
    PortalInput* self;
    guint generation;
    std::string session;
    guint serial;
    std::string text;
    GOutputStream* stream = nullptr;
    GCancellable* cancel = g_cancellable_new();
    guint timeout = 0;
    ~Transfer() {
      if (timeout) g_source_remove(timeout);
      g_object_unref(cancel);
      if (stream) g_object_unref(stream);
    }
  };
  static void finish_transfer(Transfer* t, bool success) {
    if (t->generation == t->self->generation)
      g_dbus_connection_call(t->self->bus, kDesktop, kPath, kClipboard, "SelectionWriteDone",
          g_variant_new("(oub)", t->session.c_str(), t->serial, success), nullptr,
          G_DBUS_CALL_FLAGS_NONE, 3000, nullptr, nullptr, nullptr);
    delete t;
  }
  static void clipboard_transfer(GDBusConnection*, const gchar*, const gchar*, const gchar*,
                                 const gchar*, GVariant* parameters, gpointer p) {
    auto* self = static_cast<PortalInput*>(p);
    const gchar *session, *mime;
    guint serial;
    g_variant_get(parameters, "(&o&su)", &session, &mime, &serial);
    if (!self->ready || !self->clipboard || self->session != session) return;
    auto* t = new Transfer{self, self->generation, session, serial, self->clipboard_text};
    if (t->text.empty() || (std::string(mime) != "text/plain;charset=utf-8" &&
        std::string(mime) != "text/plain" && std::string(mime) != "UTF8_STRING")) {
      finish_transfer(t, false); return;
    }
    t->timeout = g_timeout_add_seconds(10, [](gpointer p) -> gboolean {
      auto* t = static_cast<Transfer*>(p);
      t->timeout = 0;
      g_cancellable_cancel(t->cancel);
      return G_SOURCE_REMOVE;
    }, t);
    g_dbus_connection_call_with_unix_fd_list(self->bus, kDesktop, kPath, kClipboard,
        "SelectionWrite", g_variant_new("(ou)", session, serial), G_VARIANT_TYPE("(h)"),
        G_DBUS_CALL_FLAGS_NONE, 3000, nullptr, t->cancel,
        [](GObject* object, GAsyncResult* r, gpointer p) {
          auto* t = static_cast<Transfer*>(p);
          g_autoptr(GError) error = nullptr;
          g_autoptr(GUnixFDList) list = nullptr;
          g_autoptr(GVariant) result = g_dbus_connection_call_with_unix_fd_list_finish(
              G_DBUS_CONNECTION(object), &list, r, &error);
          if (!result || !list) { finish_transfer(t, false); return; }
          gint index;
          g_variant_get(result, "(h)", &index);
          gint fd = g_unix_fd_list_get(list, index, &error);
          if (fd < 0) { finish_transfer(t, false); return; }
          t->stream = g_unix_output_stream_new(fd, true);
          if (t->generation != t->self->generation) {
            g_output_stream_close(t->stream, nullptr, nullptr);
            finish_transfer(t, false);
            return;
          }
          g_output_stream_write_all_async(t->stream, t->text.data(), t->text.size(),
              G_PRIORITY_DEFAULT, t->cancel, [](GObject* object, GAsyncResult* r, gpointer p) {
                auto* t = static_cast<Transfer*>(p);
                g_autoptr(GError) error = nullptr;
                gsize written;
                bool success = g_output_stream_write_all_finish(G_OUTPUT_STREAM(object), r, &written, &error);
                // Close the pipe before notifying the consumer that the write is done.
                g_output_stream_close(t->stream, nullptr, nullptr);
                finish_transfer(t, success);
              }, t);
        }, t);
  }
};

PortalInput& portal() { static auto* input = new PortalInput(); return *input; }
}  // namespace

bool is_wayland_session() {
  return g_strcmp0(g_getenv("XDG_SESSION_TYPE"), "wayland") == 0 ||
      (gdk_display_get_default() && GDK_IS_WAYLAND_DISPLAY(gdk_display_get_default()));
}

void handle_wayland_input(FlMethodCall* call) {
  std::string method = fl_method_call_get_name(call);
  auto& input = portal();
  if (method == "inputStatus" || method == "releaseAccess") {
    if (method == "releaseAccess") input.reset("Wayland 控制已停止；请重新授权");
    g_autoptr(FlValue) status = input.status();
    fl_method_call_respond_success(call, status, nullptr);
  } else if (method == "isAvailable") {
    g_autoptr(FlValue) value = fl_value_new_bool(input.ready);
    fl_method_call_respond_success(call, value, nullptr);
  } else if (method == "requestAccess") {
    g_object_ref(call);
    input.authorize([call, &input]() {
      g_autoptr(FlValue) status = input.status();
      fl_method_call_respond_success(call, status, nullptr);
      g_object_unref(call);
    });
  } else if (method == "keyStroke" || method == "pointer" || method == "text") {
    g_object_ref(call);
    input.inject(method, fl_method_call_get_args(call), [call](int count, const std::string& error) {
      if (error.empty()) {
        g_autoptr(FlValue) result = fl_value_new_int(count);
        fl_method_call_respond_success(call, result, nullptr);
      } else {
        fl_method_call_respond_error(call, "INPUT_BLOCKED", error.c_str(), nullptr, nullptr);
      }
      g_object_unref(call);
    });
  } else {
    fl_method_call_respond_not_implemented(call, nullptr);
  }
}
