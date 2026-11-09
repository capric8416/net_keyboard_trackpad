#include "linux_input.h"
#include "wayland_input.h"
#include <gdk/gdkx.h>
#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <X11/extensions/XTest.h>
#include <array>
#include <string>
#include <vector>
#include <utility>

namespace {
// Keysyms select the base key; the active XKB layout determines characters.
KeySym keysym(const std::string& name) {
  if (name.size() == 4 && name.substr(0, 3) == "key")
    return XK_a + name[3] - 'A';
  if (name.size() == 6 && name.substr(0, 5) == "digit")
    return XK_0 + name[5] - '0';
  static const std::pair<const char*, KeySym> keys[] = {
    {"escape", XK_Escape}, {"printScreen", XK_Print}, {"delete", XK_Delete},
    {"home", XK_Home}, {"end", XK_End}, {"pageUp", XK_Page_Up},
    {"pageDown", XK_Page_Down}, {"backquote", XK_grave}, {"minus", XK_minus},
    {"equal", XK_equal}, {"backspace", XK_BackSpace}, {"tab", XK_Tab},
    {"bracketLeft", XK_bracketleft}, {"bracketRight", XK_bracketright},
    {"backslash", XK_backslash}, {"capsLock", XK_Caps_Lock},
    {"semicolon", XK_semicolon}, {"quote", XK_apostrophe}, {"enter", XK_Return},
    {"comma", XK_comma}, {"period", XK_period}, {"slash", XK_slash},
    {"arrowUp", XK_Up}, {"arrowDown", XK_Down}, {"arrowLeft", XK_Left},
    {"arrowRight", XK_Right}, {"space", XK_space}, {"menu", XK_Menu},
    {"f1", XK_F1}, {"f2", XK_F2}, {"f3", XK_F3}, {"f4", XK_F4},
    {"f5", XK_F5}, {"f6", XK_F6}, {"f7", XK_F7}, {"f8", XK_F8},
    {"f9", XK_F9}, {"f10", XK_F10}, {"f11", XK_F11}, {"f12", XK_F12},
  };
  for (const auto& key : keys) if (name == key.first) return key.second;
  return NoSymbol;
}

FlValue* field(FlValue* args, const char* key) {
  return args && fl_value_get_type(args) == FL_VALUE_TYPE_MAP
      ? fl_value_lookup_string(args, key) : nullptr;
}
std::string string_arg(FlValue* args, const char* key) {
  FlValue* value = field(args, key);
  return value && fl_value_get_type(value) == FL_VALUE_TYPE_STRING
      ? fl_value_get_string(value) : "";
}
int int_arg(FlValue* args, const char* key) {
  FlValue* value = field(args, key);
  return value && fl_value_get_type(value) == FL_VALUE_TYPE_INT
      ? fl_value_get_int(value) : 0;
}
FlMethodResponse* fail(const char* code, const char* message) {
  return FL_METHOD_RESPONSE(fl_method_error_response_new(code, message, nullptr));
}

FlMethodResponse* execute(const std::string& method, FlValue* args) {
  GdkDisplay* gdk = gdk_display_get_default();
  const char* session = g_getenv("XDG_SESSION_TYPE");
  Display* display = gdk && GDK_IS_X11_DISPLAY(gdk) &&
      g_strcmp0(session, "wayland") != 0 ? GDK_DISPLAY_XDISPLAY(gdk) : nullptr;
  int event, error, major, minor;
  const bool available = display &&
      XTestQueryExtension(display, &event, &error, &major, &minor);
  if (method == "isAvailable") {
    g_autoptr(FlValue) result = fl_value_new_bool(available);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  if (method == "inputStatus" || method == "requestAccess" || method == "releaseAccess") {
    g_autoptr(FlValue) result = fl_value_new_map();
    fl_value_set_string_take(result, "backend", fl_value_new_string("x11"));
    fl_value_set_string_take(result, "ready", fl_value_new_bool(available));
    fl_value_set_string_take(result, "busy", fl_value_new_bool(false));
    fl_value_set_string_take(result, "message", fl_value_new_string(
        available ? "X11 / XTEST 输入可用" : "X11 / XTEST 不可用"));
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  if (!available) {
    return fail("INPUT_BLOCKED", "Linux input requires an X11 session with XTEST; Wayland is unsupported.");
  }
  // Preflight every key before sending any event, so missing keycodes cannot
  // leave modifiers down. Never hold modifiers across commands.
  std::vector<std::pair<KeyCode, bool>> events;
  auto stroke = [&](KeySym symbol, int bits) {
    const std::array<KeySym, 8> modifiers = {XK_Control_L, XK_Control_R,
      XK_Alt_L, XK_Alt_R, XK_Shift_L, XK_Shift_R, XK_Super_L, XK_Super_R};
    if (symbol == NoSymbol) return false;
    KeyCode key = XKeysymToKeycode(display, symbol);
    if (!key || bits < 0 || bits > 255) return false;
    std::vector<KeyCode> selected;
    for (size_t i = 0; i < modifiers.size(); ++i) {
      if (!(bits & (1 << i))) continue;
      KeyCode code = XKeysymToKeycode(display, modifiers[i]);
      if (!code) return false;
      selected.push_back(code);
    }
    for (auto code : selected) events.emplace_back(code, true);
    events.emplace_back(key, true);
    events.emplace_back(key, false);
    for (auto i = selected.rbegin(); i != selected.rend(); ++i)
      events.emplace_back(*i, false);
    return true;
  };
  int count = 0;
  if (method == "keyStroke" || method == "text") {
    Window focus;
    int revert;
    XGetInputFocus(display, &focus, &revert);
    if (focus == None)
      return fail("NO_FOREGROUND_TARGET", "No X11 input focus.");
    if (method == "text") {
      std::string text = string_arg(args, "text");
      if (text.empty() || !g_utf8_validate(text.c_str(), text.size(), nullptr)) {
        return fail("INVALID_ARGUMENT", "Text must be nonempty UTF-8.");
      }
      // Shift+Insert uses CLIPBOARD in many widgets and PRIMARY in X11
      // terminals. Own both selections so both receive the confirmed text.
      if (!stroke(XK_Insert, 1 << 4)) {
        return fail("INPUT_BLOCKED", "Paste keys are unavailable in the active keymap.");
      }
      GtkClipboard* clipboard = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
      gtk_clipboard_set_text(clipboard, text.c_str(), text.size());
      gtk_clipboard_set_text(gtk_clipboard_get(GDK_SELECTION_PRIMARY),
                             text.c_str(), text.size());
      // Keep ownership until the target requests the selection asynchronously.
    } else if (!stroke(keysym(string_arg(args, "key")), int_arg(args, "modifiers"))) {
      return fail("INPUT_BLOCKED", "Key is unavailable in the active X11 keymap.");
    }
    for (const auto& e : events)
      count += XTestFakeKeyEvent(display, e.first, e.second, CurrentTime) != 0;
  } else if (method == "pointer") {
    int dx = int_arg(args, "deltaX"), dy = int_arg(args, "deltaY");
    if (dx || dy) count += XTestFakeRelativeMotionEvent(display, dx, dy, CurrentTime) != 0;
    const std::string button = string_arg(args, "button");
    int number = button == "left" ? 1 : button == "middle" ? 2 : button == "right" ? 3 : 0;
    if (number) {
      FlValue* down = field(args, "buttonDown");
      bool pressed = down && fl_value_get_type(down) == FL_VALUE_TYPE_BOOL && fl_value_get_bool(down);
      count += XTestFakeButtonEvent(display, number, pressed, CurrentTime) != 0;
    }
    // Protocol wheel units match Windows: 120 units per notch. Retain small
    // gesture deltas until they form a complete X11 wheel button click.
    static int vertical = 0, horizontal = 0;
    vertical += int_arg(args, "wheelDelta");
    horizontal += int_arg(args, "horizontalWheelDelta");
    auto wheel = [&](int& remainder, int positive, int negative) {
      while (remainder >= 120 || remainder <= -120) {
        int button = remainder > 0 ? positive : negative;
        count += XTestFakeButtonEvent(display, button, True, CurrentTime) != 0;
        count += XTestFakeButtonEvent(display, button, False, CurrentTime) != 0;
        remainder += remainder > 0 ? -120 : 120;
      }
    };
    wheel(vertical, 4, 5);
    wheel(horizontal, 7, 6);
  } else {
    return FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  XSync(display, False);
  g_autoptr(FlValue) result = fl_value_new_int(count);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}
void handle(FlMethodChannel*, FlMethodCall* call, gpointer) {
  if (is_wayland_session()) {
    handle_wayland_input(call);
    return;
  }
  g_autoptr(FlMethodResponse) response = execute(
      fl_method_call_get_name(call), fl_method_call_get_args(call));
  fl_method_call_respond(call, response, nullptr);
}
}  // namespace

void register_linux_input(FlBinaryMessenger* messenger) {
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      messenger, "net_keyboard/input", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, handle, nullptr, nullptr);
}
