// Run only under dbus-run-session: never use the real desktop portal.
#include "../wayland_input.cc"
#include <cassert>
#include <chrono>
#include <iostream>
#include <fcntl.h>
#include <unistd.h>

namespace {
const char* xml = R"XML(<node>
<interface name="org.freedesktop.portal.RemoteDesktop">
 <method name="CreateSession"><arg type="a{sv}" direction="in"/><arg type="o" direction="out"/></method>
 <method name="SelectDevices"><arg type="o" direction="in"/><arg type="a{sv}" direction="in"/><arg type="o" direction="out"/></method>
 <method name="Start"><arg type="o" direction="in"/><arg type="s" direction="in"/><arg type="a{sv}" direction="in"/><arg type="o" direction="out"/></method>
 <method name="NotifyKeyboardKeycode"><arg type="o" direction="in"/><arg type="a{sv}" direction="in"/><arg type="i" direction="in"/><arg type="u" direction="in"/></method>
 <method name="NotifyPointerMotion"><arg type="o" direction="in"/><arg type="a{sv}" direction="in"/><arg type="d" direction="in"/><arg type="d" direction="in"/></method>
 <method name="NotifyPointerButton"><arg type="o" direction="in"/><arg type="a{sv}" direction="in"/><arg type="i" direction="in"/><arg type="u" direction="in"/></method>
 <method name="NotifyPointerAxisDiscrete"><arg type="o" direction="in"/><arg type="a{sv}" direction="in"/><arg type="u" direction="in"/><arg type="i" direction="in"/></method>
</interface>
<interface name="org.freedesktop.portal.Clipboard">
 <method name="RequestClipboard"><arg type="o" direction="in"/><arg type="a{sv}" direction="in"/></method>
 <method name="SetSelection"><arg type="o" direction="in"/><arg type="a{sv}" direction="in"/></method>
 <method name="SelectionWrite"><arg type="o" direction="in"/><arg type="u" direction="in"/><arg type="h" direction="out"/></method>
 <method name="SelectionWriteDone"><arg type="o" direction="in"/><arg type="u" direction="in"/><arg type="b" direction="in"/></method>
</interface>
</node>)XML";
const char* session_path = "/org/freedesktop/portal/desktop/session/mock/test";
struct Mock {
  GDBusConnection* bus;
  int response_code = 0;
  guint devices = 3;
  bool allow_clipboard = true;
  bool fail_clipboard_request = false;
  bool selection = false;
  bool transfer_done = false;
  bool request_clipboard_before_start = false;
  int fail_key_number = 0;
  int key_count = 0;
  int reader = -1;
  std::vector<std::pair<int, guint>> keys;
  std::vector<std::pair<guint, int>> axes;
  std::vector<std::pair<int, guint>> buttons;
  int motions = 0;
};
void until(const std::function<bool()>& done) {
  auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(10);
  while (!done() && std::chrono::steady_clock::now() < deadline) {
    while (g_main_context_iteration(nullptr, false)) {}
    g_usleep(1000);
  }
  assert(done());
}
void mock_method(GDBusConnection*, const gchar* sender, const gchar*, const gchar*,
                 const gchar* name, GVariant* params, GDBusMethodInvocation* invocation, gpointer data) {
  auto& m = *static_cast<Mock*>(data);
  std::string method = name;
  if (method == "CreateSession" || method == "SelectDevices" || method == "Start") {
    g_autoptr(GVariant) opts = g_variant_get_child_value(params, g_variant_n_children(params) - 1);
    const char* token = nullptr;
    assert(g_variant_lookup(opts, "handle_token", "&s", &token));
    std::string id = sender + 1;
    for (auto& c : id) if (c == '.') c = '_';
    std::string path = "/org/freedesktop/portal/desktop/request/" + id + "/" + token;
    GVariantBuilder result;
    g_variant_builder_init(&result, G_VARIANT_TYPE_VARDICT);
    if (method == "CreateSession")
      g_variant_builder_add(&result, "{sv}", "session_handle", g_variant_new_string(session_path));
    if (method == "SelectDevices") {
      guint devices = 0;
      assert(g_variant_lookup(opts, "types", "u", &devices) && devices == 3);
    }
    if (method == "Start") {
      assert(m.request_clipboard_before_start);
      g_variant_builder_add(&result, "{sv}", "devices", g_variant_new_uint32(m.devices));
      g_variant_builder_add(&result, "{sv}", "clipboard_enabled", g_variant_new_boolean(m.allow_clipboard));
    }
    g_dbus_method_invocation_return_value(invocation, g_variant_new("(o)", path.c_str()));
    // Emit immediately: client must subscribe before invoking the request.
    g_dbus_connection_emit_signal(m.bus, sender, path.c_str(), "org.freedesktop.portal.Request", "Response",
        g_variant_new("(u@a{sv})", method == "Start" ? m.response_code : 0, g_variant_builder_end(&result)), nullptr);
    return;
  }
  if (method == "RequestClipboard") {
    m.request_clipboard_before_start = true;
    if (m.fail_clipboard_request) {
      g_dbus_method_invocation_return_dbus_error(invocation, "org.freedesktop.DBus.Error.UnknownMethod", "Clipboard unavailable");
      return;
    }
  } else if (method == "NotifyKeyboardKeycode") {
    g_autoptr(GVariant) key = g_variant_get_child_value(params, 2);
    g_autoptr(GVariant) state = g_variant_get_child_value(params, 3);
    int code = g_variant_get_int32(key);
    guint pressed = g_variant_get_uint32(state);
    m.keys.emplace_back(code, pressed);
    if (++m.key_count == m.fail_key_number) {
      g_dbus_method_invocation_return_dbus_error(invocation, "org.freedesktop.DBus.Error.Failed", "Revoked");
      return;
    }
    if (m.selection && code == KEY_V && pressed) {
      m.selection = false;
      g_dbus_connection_emit_signal(m.bus, sender, kPath, kClipboard, "SelectionTransfer",
          g_variant_new("(osu)", session_path, "text/plain;charset=utf-8", 123u), nullptr);
    }
  } else if (method == "NotifyPointerMotion") {
    ++m.motions;
  } else if (method == "NotifyPointerButton") {
    g_autoptr(GVariant) button = g_variant_get_child_value(params, 2);
    g_autoptr(GVariant) state = g_variant_get_child_value(params, 3);
    m.buttons.emplace_back(g_variant_get_int32(button), g_variant_get_uint32(state));
  } else if (method == "NotifyPointerAxisDiscrete") {
    g_autoptr(GVariant) axis = g_variant_get_child_value(params, 2);
    g_autoptr(GVariant) steps = g_variant_get_child_value(params, 3);
    m.axes.emplace_back(g_variant_get_uint32(axis), g_variant_get_int32(steps));
  } else if (method == "SetSelection") {
    m.selection = true;
    m.transfer_done = false;
  } else if (method == "SelectionWrite") {
    int pipes[2];
    assert(pipe2(pipes, O_CLOEXEC | O_NONBLOCK) == 0);
    m.reader = pipes[0];
    g_autoptr(GUnixFDList) list = g_unix_fd_list_new();
    int index = g_unix_fd_list_append(list, pipes[1], nullptr);
    close(pipes[1]);
    g_dbus_method_invocation_return_value_with_unix_fd_list(invocation, g_variant_new("(h)", index), list);
    return;
  } else if (method == "SelectionWriteDone") {
    g_autoptr(GVariant) success = g_variant_get_child_value(params, 2);
    assert(g_variant_get_boolean(success));
    m.transfer_done = true;
  }
  g_dbus_method_invocation_return_value(invocation, g_variant_new("()"));
}
}  // namespace

int main() {
  // The harness sets this marker only inside a private dbus-run-session.
  assert(g_strcmp0(g_getenv("NET_KEYBOARD_PORTAL_TEST"), "1") == 0);
  g_autoptr(GError) error = nullptr;
  auto* bus = g_bus_get_sync(G_BUS_TYPE_SESSION, nullptr, &error);
  assert(bus && !error);
  g_autoptr(GVariant) ownership = g_dbus_connection_call_sync(bus, "org.freedesktop.DBus",
      "/org/freedesktop/DBus", "org.freedesktop.DBus", "RequestName",
      g_variant_new("(su)", kDesktop, 4u), G_VARIANT_TYPE("(u)"), G_DBUS_CALL_FLAGS_NONE, 1000, nullptr, &error);
  assert(ownership && !error);
  auto* node = g_dbus_node_info_new_for_xml(xml, &error);
  assert(node && !error);
  Mock mock{bus};
  const GDBusInterfaceVTable vtable = {mock_method, nullptr, nullptr, {nullptr}};
  for (int i = 0; node->interfaces[i]; ++i)
    assert(g_dbus_connection_register_object(bus, kPath, node->interfaces[i], &vtable, &mock, nullptr, &error));
  PortalInput input;
  bool authorized = false;
  input.authorize([&]() { authorized = true; });
  until([&]() { return authorized; });
  assert(input.ready && input.clipboard && !input.busy);

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "key", fl_value_new_string("keyC"));
  fl_value_set_string_take(args, "modifiers", fl_value_new_int(0x81));
  auto inject = [&](const char* method, bool success = true) {
    bool completed = false;
    input.inject(method, args, [&](int, const std::string& error) {
      assert(error.empty() == success);
      completed = true;
    });
    until([&]() { return completed; });
  };
  inject("keyStroke");
  const std::vector<std::pair<int, guint>> expected = {
    {KEY_LEFTCTRL, 1}, {KEY_RIGHTMETA, 1}, {KEY_C, 1},
    {KEY_C, 0}, {KEY_RIGHTMETA, 0}, {KEY_LEFTCTRL, 0},
  };
  assert(mock.keys == expected);

  fl_value_set_string_take(args, "wheelDelta", fl_value_new_int(60));
  inject("pointer"); assert(mock.axes.empty());
  inject("pointer");
  assert(mock.axes.size() == 1 && mock.axes[0] == std::make_pair(0u, -1));
  fl_value_set_string_take(args, "wheelDelta", fl_value_new_int(0));
  fl_value_set_string_take(args, "horizontalWheelDelta", fl_value_new_int(120));
  fl_value_set_string_take(args, "deltaX", fl_value_new_int(12));
  fl_value_set_string_take(args, "button", fl_value_new_string("right"));
  fl_value_set_string_take(args, "buttonDown", fl_value_new_bool(true));
  inject("pointer");
  assert(mock.axes.back() == std::make_pair(1u, 1));
  assert(mock.motions == 1 && mock.buttons.back() == std::make_pair(BTN_RIGHT, 1u));
  fl_value_set_string_take(args, "buttonDown", fl_value_new_bool(false));
  inject("pointer"); assert(mock.buttons.back() == std::make_pair(BTN_RIGHT, 0u));

  fl_value_set_string_take(args, "text", fl_value_new_string("中文😀\nline two"));
  inject("text");
  until([&]() { return mock.transfer_done; });
  char text[256];
  ssize_t size = read(mock.reader, text, sizeof(text));
  assert(size > 0 && std::string(text, size) == "中文😀\nline two");
  close(mock.reader);
  assert(mock.keys[mock.keys.size() - 4] == std::make_pair(KEY_LEFTCTRL, 1u));

  fl_value_set_string_take(args, "terminalPaste", fl_value_new_int(1));
  inject("text");
  until([&]() { return mock.transfer_done; });
  close(mock.reader);
  assert(mock.keys[mock.keys.size() - 6] == std::make_pair(KEY_LEFTCTRL, 1u));
  assert(mock.keys[mock.keys.size() - 5] == std::make_pair(KEY_LEFTSHIFT, 1u));

  g_dbus_connection_emit_signal(bus, nullptr, session_path, "org.freedesktop.portal.Session", "Closed",
      g_variant_new("(a{sv})", nullptr), nullptr);
  until([&]() { return !input.ready; });
  inject("keyStroke", false);
  // Denied/partial grants never enable input and can be retried.
  mock.response_code = 1;
  authorized = false;
  input.authorize([&]() { authorized = true; });
  until([&]() { return authorized; }); assert(!input.ready);
  mock.response_code = 0;
  mock.devices = 1;
  authorized = false;
  input.authorize([&]() { authorized = true; });
  until([&]() { return authorized; }); assert(!input.ready);
  mock.devices = 3;
  mock.allow_clipboard = false;
  mock.fail_clipboard_request = true;
  authorized = false;
  input.authorize([&]() { authorized = true; });
  until([&]() { return authorized; }); assert(input.ready && !input.clipboard);
  inject("text", false);
  inject("keyStroke");

  mock.fail_key_number = mock.key_count + 2;
  size_t start = mock.keys.size();
  inject("keyStroke", false);
  assert(!input.ready);
  // A failed second modifier must skip the main key press, but release both modifiers.
  assert(mock.keys.size() == start + 4);
  for (size_t i = start + 2; i < mock.keys.size(); ++i) assert(mock.keys[i].second == 0);
  std::cout << "Wayland portal validation passed: authorization, cancellation/retry, revocation, atomic keys, pointer/axes, Unicode FD transfer, terminal paste, partial grants and failure cleanup\n";
}
