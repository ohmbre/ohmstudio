#include <QObject>
#include <QString>
#include <QDebug>
#include <QThread>
#include <QIODevice>
#include <QJSValue>
#include <QVariant>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

constexpr auto SAMPLES_PER_SECOND = 48000;
constexpr auto BYTES_PER_SAMPLE = 2;
constexpr auto NCHANNELS = 2;
constexpr auto SAMPLES_PER_FRAME = NCHANNELS;
constexpr auto BYTES_PER_FRAME = BYTES_PER_SAMPLE*NCHANNELS;
constexpr auto FRAMES_PER_PERIOD = 1024LL;
constexpr auto BYTES_PER_PERIOD = FRAMES_PER_PERIOD * BYTES_PER_FRAME; // 4096
constexpr auto SAMPLES_PER_PERIOD = FRAMES_PER_PERIOD * SAMPLES_PER_FRAME;

void ioloop(QIODevice *out, QIODevice *in);
void initBackend(QQmlApplicationEngine *engine);
void initHWIO(QQmlApplicationEngine *engine);
