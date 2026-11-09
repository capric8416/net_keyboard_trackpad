cmake_minimum_required(VERSION 3.22.1)
project(net_keyboard_asr LANGUAGES CXX)

set(VENDOR "${CMAKE_CURRENT_SOURCE_DIR}/vendor/android-${ANDROID_ABI}")
add_library(net_keyboard_asr SHARED asr_bridge.cpp)
target_compile_features(net_keyboard_asr PRIVATE cxx_std_17)
target_compile_options(net_keyboard_asr PRIVATE -fexceptions)
target_link_libraries(net_keyboard_asr PRIVATE log android atomic m)
target_link_options(net_keyboard_asr PRIVATE "LINKER:-z,noexecstack")

if(NOT EXISTS "${VENDOR}/lib/libzh_speech_deps.a")
  message(FATAL_ERROR
    "FunASR Android native dependencies are missing. Run: "
    "uv run python scripts/prepare_funasr.py --build-native")
endif()

target_compile_definitions(net_keyboard_asr PRIVATE NET_KEYBOARD_HAS_FUNASR=1)
target_include_directories(net_keyboard_asr PRIVATE "${VENDOR}/include")
target_link_libraries(net_keyboard_asr PRIVATE
  "${VENDOR}/lib/libzh_speech_deps.a"
  z dl)
