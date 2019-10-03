#ifndef INCLUDE_COMMON_HPP
#define INCLUDE_COMMON_HPP

#define V double
#define Sample short
#define MADRE QGuiApplication::instance()
#define maestro Conductor::instance()



constexpr auto FRAMES_PER_SEC = 48000;
constexpr auto FRAMES_PER_NSEC = 0.000048;
constexpr auto BYTES_PER_SAMPLE = 2;
constexpr auto FRAMES_PER_PERIOD = 3840;
constexpr auto MSEC_PER_PERIOD = FRAMES_PER_PERIOD / 48;
constexpr auto MAX_CHANNELS = 8;

void register_symbolic();


#endif


