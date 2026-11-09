#pragma once
#include <flutter_linux/flutter_linux.h>

bool is_wayland_session();
void handle_wayland_input(FlMethodCall* call);
