cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES C CXX)

# Embed the icon so taskbar/window icons work from any launch directory.
find_program(GLIB_COMPILE_RESOURCES glib-compile-resources)
if(NOT GLIB_COMPILE_RESOURCES)
  message(FATAL_ERROR "glib-compile-resources is required for the Linux app icon")
endif()
set(APP_RESOURCES "${CMAKE_CURRENT_BINARY_DIR}/app_resources.c")
add_custom_command(
  OUTPUT "${APP_RESOURCES}"
  COMMAND "${GLIB_COMPILE_RESOURCES}"
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/app.gresource.xml"
    --sourcedir=${CMAKE_CURRENT_SOURCE_DIR}/resources
    --target=${APP_RESOURCES} --generate-source
  DEPENDS resources/app.gresource.xml resources/app_icon.png
  VERBATIM
)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "linux_input.cc"
  "${APP_RESOURCES}"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
pkg_check_modules(XINPUT REQUIRED IMPORTED_TARGET x11 xtst)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::XINPUT)
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
