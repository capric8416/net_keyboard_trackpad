#pragma once
#include <linux/input-event-codes.h>
#include <array>
#include <string>
#include <utility>

// Evdev physical positions, independent of the active compositor keymap.
inline int linux_key_code(const std::string& name) {
  static const std::pair<const char*, int> keys[] = {
    {"escape", KEY_ESC}, {"f1", KEY_F1}, {"f2", KEY_F2}, {"f3", KEY_F3},
    {"f4", KEY_F4}, {"f5", KEY_F5}, {"f6", KEY_F6}, {"f7", KEY_F7},
    {"f8", KEY_F8}, {"f9", KEY_F9}, {"f10", KEY_F10}, {"f11", KEY_F11},
    {"f12", KEY_F12}, {"printScreen", KEY_SYSRQ}, {"delete", KEY_DELETE},
    {"home", KEY_HOME}, {"end", KEY_END}, {"pageUp", KEY_PAGEUP},
    {"pageDown", KEY_PAGEDOWN}, {"backquote", KEY_GRAVE},
    {"digit1", KEY_1}, {"digit2", KEY_2}, {"digit3", KEY_3}, {"digit4", KEY_4},
    {"digit5", KEY_5}, {"digit6", KEY_6}, {"digit7", KEY_7}, {"digit8", KEY_8},
    {"digit9", KEY_9}, {"digit0", KEY_0}, {"minus", KEY_MINUS},
    {"equal", KEY_EQUAL}, {"backspace", KEY_BACKSPACE}, {"tab", KEY_TAB},
    {"keyQ", KEY_Q}, {"keyW", KEY_W}, {"keyE", KEY_E}, {"keyR", KEY_R},
    {"keyT", KEY_T}, {"keyY", KEY_Y}, {"keyU", KEY_U}, {"keyI", KEY_I},
    {"keyO", KEY_O}, {"keyP", KEY_P}, {"bracketLeft", KEY_LEFTBRACE},
    {"bracketRight", KEY_RIGHTBRACE}, {"backslash", KEY_BACKSLASH},
    {"capsLock", KEY_CAPSLOCK}, {"keyA", KEY_A}, {"keyS", KEY_S},
    {"keyD", KEY_D}, {"keyF", KEY_F}, {"keyG", KEY_G}, {"keyH", KEY_H},
    {"keyJ", KEY_J}, {"keyK", KEY_K}, {"keyL", KEY_L},
    {"semicolon", KEY_SEMICOLON}, {"quote", KEY_APOSTROPHE},
    {"enter", KEY_ENTER}, {"keyZ", KEY_Z}, {"keyX", KEY_X}, {"keyC", KEY_C},
    {"keyV", KEY_V}, {"keyB", KEY_B}, {"keyN", KEY_N}, {"keyM", KEY_M},
    {"comma", KEY_COMMA}, {"period", KEY_DOT}, {"slash", KEY_SLASH},
    {"arrowUp", KEY_UP}, {"arrowDown", KEY_DOWN}, {"arrowLeft", KEY_LEFT},
    {"arrowRight", KEY_RIGHT}, {"space", KEY_SPACE}, {"menu", KEY_COMPOSE},
  };
  for (const auto& key : keys) if (name == key.first) return key.second;
  return 0;
}

inline const std::array<int, 8>& linux_modifier_codes() {
  static const std::array<int, 8> codes = {KEY_LEFTCTRL, KEY_RIGHTCTRL,
    KEY_LEFTALT, KEY_RIGHTALT, KEY_LEFTSHIFT, KEY_RIGHTSHIFT,
    KEY_LEFTMETA, KEY_RIGHTMETA};
  return codes;
}
