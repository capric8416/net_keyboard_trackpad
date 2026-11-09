// Built and run in an isolated Xvfb session by scripts/test_linux_input.py.
#include "../linux_input.cc"
#include <cassert>
#include <iostream>

int main(int argc, char** argv) {
  gtk_init(nullptr, nullptr);
  assert(GDK_IS_X11_DISPLAY(gdk_display_get_default()));
  Display* d = GDK_DISPLAY_XDISPLAY(gdk_display_get_default());
  Window window = XCreateSimpleWindow(d, DefaultRootWindow(d), 0, 0, 300, 300,
                                       0, 0, 0);
  XSelectInput(d, window, KeyPressMask | KeyReleaseMask);
  XMapWindow(d, window);
  XSetInputFocus(d, window, RevertToParent, CurrentTime);
  XSync(d, False);
  g_autoptr(FlValue) args = fl_value_new_map();
  // Check all shared semantic keys against the native map and Xvfb keymap.
  for (int i = 1; i < argc; ++i) {
    assert(keysym(argv[i]) != NoSymbol);
    assert(XKeysymToKeycode(d, keysym(argv[i])) != 0);
  }
  assert(argc == 77);
  fl_value_set_string_take(args, "key", fl_value_new_string("keyC"));
  fl_value_set_string_take(args, "modifiers", fl_value_new_int(0x81));
  g_autoptr(FlMethodResponse) response = execute("keyStroke", args);
  assert(FL_IS_METHOD_SUCCESS_RESPONSE(response));
  assert(fl_value_get_int(fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(response))) == 6);
  const KeySym expected[] = {XK_Control_L, XK_Super_R, XK_c, XK_c, XK_Super_R, XK_Control_L};
  for (int i = 0; i < 6; ++i) {
    XEvent e;
    do { XNextEvent(d, &e); } while (e.type != KeyPress && e.type != KeyRelease);
    assert(e.type == (i < 3 ? KeyPress : KeyRelease));
    assert(e.xkey.keycode == XKeysymToKeycode(d, expected[i]));
  }
  for (int i = 0; i < 8; ++i) {
    fl_value_set_string_take(args, "modifiers", fl_value_new_int(1 << i));
    g_autoptr(FlMethodResponse) r = execute("keyStroke", args);
    assert(FL_IS_METHOD_SUCCESS_RESPONSE(r));
    assert(fl_value_get_int(fl_method_success_response_get_result(
        FL_METHOD_SUCCESS_RESPONSE(r))) == 4);
  }
  fl_value_set_string_take(args, "modifiers", fl_value_new_int(256));
  g_autoptr(FlMethodResponse) invalid = execute("keyStroke", args);
  assert(FL_IS_METHOD_ERROR_RESPONSE(invalid));
  fl_value_set_string_take(args, "text", fl_value_new_string("中文😀\nsecond line"));
  g_autoptr(FlMethodResponse) text = execute("text", args);
  assert(FL_IS_METHOD_SUCCESS_RESPONSE(text));
  g_autofree char* clipboard = gtk_clipboard_wait_for_text(gtk_clipboard_get(GDK_SELECTION_CLIPBOARD));
  assert(std::string(clipboard) == "中文😀\nsecond line");
  g_autofree char* primary = gtk_clipboard_wait_for_text(gtk_clipboard_get(GDK_SELECTION_PRIMARY));
  assert(std::string(primary) == "中文😀\nsecond line");
  // Fractional scroll requests accumulate into one press/release pair.
  fl_value_set_string_take(args, "wheelDelta", fl_value_new_int(60));
  for (int i = 0; i < 2; ++i) {
    g_autoptr(FlMethodResponse) r = execute("pointer", args);
    assert(fl_value_get_int(fl_method_success_response_get_result(
        FL_METHOD_SUCCESS_RESPONSE(r))) == (i == 0 ? 0 : 2));
  }
  fl_value_set_string_take(args, "wheelDelta", fl_value_new_int(0));
  fl_value_set_string_take(args, "horizontalWheelDelta", fl_value_new_int(-120));
  fl_value_set_string_take(args, "deltaX", fl_value_new_int(12));
  fl_value_set_string_take(args, "deltaY", fl_value_new_int(-8));
  fl_value_set_string_take(args, "button", fl_value_new_string("right"));
  fl_value_set_string_take(args, "buttonDown", fl_value_new_bool(true));
  g_autoptr(FlMethodResponse) pointer = execute("pointer", args);
  assert(fl_value_get_int(fl_method_success_response_get_result(
      FL_METHOD_SUCCESS_RESPONSE(pointer))) == 4);
  fl_value_set_string_take(args, "buttonDown", fl_value_new_bool(false));
  g_autoptr(FlMethodResponse) release = execute("pointer", args);
  assert(FL_IS_METHOD_SUCCESS_RESPONSE(release));
  XSetInputFocus(d, None, RevertToNone, CurrentTime);
  g_autoptr(FlMethodResponse) no_focus = execute("text", args);
  assert(FL_IS_METHOD_ERROR_RESPONSE(no_focus));
  assert(std::string(fl_method_error_response_get_code(FL_METHOD_ERROR_RESPONSE(no_focus))) == "NO_FOREGROUND_TARGET");
  g_setenv("XDG_SESSION_TYPE", "wayland", true);
  g_autoptr(FlMethodResponse) blocked = execute("text", args);
  assert(FL_IS_METHOD_ERROR_RESPONSE(blocked));
  assert(std::string(fl_method_error_response_get_code(FL_METHOD_ERROR_RESPONSE(blocked))) == "INPUT_BLOCKED");
  XDestroyWindow(d, window);
  std::cout << "Linux X11 input validation passed: 76 keys, 8 modifiers, Unicode clipboard, pointer, wheel, session/focus errors\n";
}
