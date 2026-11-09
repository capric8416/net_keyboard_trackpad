#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#ifdef NET_KEYBOARD_HAS_FUNASR
#include <funasrruntime.h>

namespace {
struct AsrHandle {
  FUNASR_HANDLE asr = nullptr;
  FUNASR_HANDLE vad = nullptr;
  std::mutex mutex;
  ~AsrHandle() {
    if (vad != nullptr) FsmnVadUninit(vad);
    if (asr != nullptr) FunOfflineUninit(asr);
  }
};

uint16_t read_u16(const unsigned char *p) {
  return static_cast<uint16_t>(p[0]) | (static_cast<uint16_t>(p[1]) << 8);
}
uint32_t read_u32(const unsigned char *p) {
  return static_cast<uint32_t>(p[0]) | (static_cast<uint32_t>(p[1]) << 8) |
         (static_cast<uint32_t>(p[2]) << 16) | (static_cast<uint32_t>(p[3]) << 24);
}

bool read_pcm16(const char *path, std::vector<unsigned char> &audio,
                int &sample_rate) {
  std::ifstream input(path, std::ios::binary);
  unsigned char riff[12]{};
  if (!input.read(reinterpret_cast<char *>(riff), sizeof(riff)) ||
      std::memcmp(riff, "RIFF", 4) != 0 || std::memcmp(riff + 8, "WAVE", 4) != 0)
    return false;
  uint16_t format = 0, channels = 0, bits = 0;
  uint32_t rate = 0;
  while (input) {
    unsigned char chunk[8]{};
    if (!input.read(reinterpret_cast<char *>(chunk), sizeof(chunk))) break;
    const uint32_t size = read_u32(chunk + 4);
    if (std::memcmp(chunk, "fmt ", 4) == 0 && size >= 16) {
      std::vector<unsigned char> data(size);
      if (!input.read(reinterpret_cast<char *>(data.data()), size)) return false;
      format = read_u16(data.data()); channels = read_u16(data.data() + 2);
      rate = read_u32(data.data() + 4); bits = read_u16(data.data() + 14);
    } else if (std::memcmp(chunk, "data", 4) == 0) {
      audio.resize(size);
      if (!input.read(reinterpret_cast<char *>(audio.data()), size)) return false;
    } else {
      input.seekg(size, std::ios::cur);
    }
    if ((size & 1U) != 0) input.seekg(1, std::ios::cur);
  }
  if (format != 1 || channels != 1 || bits != 16 || rate == 0 ||
      audio.size() < rate * 2 / 5) return false;
  double energy = 0;
  for (size_t i = 0; i < audio.size() / 2; ++i) {
    const auto sample = static_cast<int16_t>(read_u16(audio.data() + i * 2));
    energy += static_cast<double>(sample) * sample;
  }
  if (std::sqrt(energy / (audio.size() / 2)) < 64.0) return false;
  sample_rate = static_cast<int>(rate);
  return true;
}
}  // namespace
#endif

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void *net_asr_create(const char *model_dir, const char *vad_dir) {
#ifdef NET_KEYBOARD_HAS_FUNASR
  if (!model_dir || !vad_dir) return nullptr;
  try {
    auto handle = std::make_unique<AsrHandle>();
    std::map<std::string, std::string> asr{{"model-dir", model_dir}, {"quantize", "true"}};
    std::map<std::string, std::string> vad{{"model-dir", vad_dir}, {"quantize", "true"}};
    handle->asr = FunOfflineInit(asr, 2, false, 1);
    handle->vad = FsmnVadInit(vad, 1);
    return handle->asr && handle->vad ? handle.release() : nullptr;
  } catch (...) { return nullptr; }
#else
  return nullptr;
#endif
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void net_asr_destroy(void *handle) {
#ifdef NET_KEYBOARD_HAS_FUNASR
  delete static_cast<AsrHandle *>(handle);
#endif
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t net_asr_recognize_wav(void *handle, const char *wav, char *output,
                              int32_t capacity) {
#ifdef NET_KEYBOARD_HAS_FUNASR
  if (!handle || !wav || !output || capacity <= 0) return -1;
  try {
    auto *speech = static_cast<AsrHandle *>(handle);
    std::lock_guard<std::mutex> lock(speech->mutex);
    std::vector<unsigned char> pcm;
    int rate = 0;
    if (!read_pcm16(wav, pcm, rate)) return -3;
    FUNASR_RESULT vad_result = FsmnVadInferBuffer(
        speech->vad, reinterpret_cast<const char *>(pcm.data()),
        static_cast<int>(pcm.size()), nullptr, true, rate, "pcm");
    if (!vad_result) return -2;
    const auto *segments = FsmnVadGetResult(vad_result, 0);
    const bool audible = segments && !segments->empty();
    FsmnVadFreeResult(vad_result);
    if (!audible) return -3;
    FUNASR_RESULT result = FunOfflineInferBuffer(
        speech->asr, reinterpret_cast<const char *>(pcm.data()),
        static_cast<int>(pcm.size()), RASR_NONE, nullptr, {{0.0f}}, rate,
        "pcm", false, nullptr);
    if (!result) return -4;
    const char *raw = FunASRGetResult(result, 0);
    const std::string text = raw ? raw : "";
    FunASRFreeResult(result);
    if (static_cast<int32_t>(text.size()) + 1 > capacity) return -5;
    std::memcpy(output, text.data(), text.size());
    output[text.size()] = '\0';
    return static_cast<int32_t>(text.size());
  } catch (...) { return -6; }
#else
  return -100;
#endif
}
