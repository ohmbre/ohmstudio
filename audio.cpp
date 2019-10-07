#include "audio.hpp"

AudioHWInfo::AudioHWInfo() : QObject(QGuiApplication::instance()) {}

QAudioFormat AudioHWInfo::getFormat() {
    QAudioFormat format;
    format.setChannelCount(2);
    format.setSampleRate(FRAMES_PER_SEC);
    format.setSampleSize(8*BYTES_PER_SAMPLE);
    format.setSampleType(QAudioFormat::SignedInt);
    format.setCodec("audio/pcm");
    format.setByteOrder(QAudioFormat::LittleEndian);
    return format;
}

QStringList AudioHWInfo::availableDevs(QAudio::Mode mode) {
    QStringList names;
    qDebug() << "\n\n\n-------------------------------------------------------------------------------";
    foreach(QAudioDeviceInfo dev, QAudioDeviceInfo::availableDevices(mode))
        if (dev.deviceName() != "pulse" && dev.isFormatSupported(getFormat()))
            names << dev.deviceName();
    qDebug() << "-------------------------------------------------------------------------------\n\n\n";
    return names;
}

QStringList AudioHWInfo::availableInDevs() {
    return availableDevs(QAudio::AudioInput);
}

QStringList AudioHWInfo::availableOutDevs() {
    return availableDevs(QAudio::AudioOutput);
}


QAudioDeviceInfo AudioHWInfo::devInfo(const QString name, QAudio::Mode mode) {
    QList<QAudioDeviceInfo> devs = QAudioDeviceInfo::availableDevices(mode);
    QList<QAudioDeviceInfo>::iterator dev;
    for (dev = devs.begin(); dev != devs.end(); ++dev)
        if (dev->deviceName() == name && dev->isFormatSupported(getFormat()))
            return *dev;
    qWarning() << "device doesnt exist or support format:" << name;
    return QAudioDeviceInfo();
}

Q_INVOKABLE AudioOut* AudioHWInfo::createOutput(const QString devName) {
    QAudioDeviceInfo info = devInfo(devName, QAudio::AudioOutput);
    if (info.isNull()) return nullptr;
    AudioOut *out = new AudioOut(info);
    return out;
}

Q_INVOKABLE AudioIn* AudioHWInfo::createInput(const QString devName) {
    QAudioDeviceInfo info = devInfo(devName, QAudio::AudioInput);
    if (info.isNull()) return nullptr;
    AudioIn *in = new AudioIn(info);
    return in;
}


AudioIn::AudioIn(QAudioDeviceInfo info)
    : QIODevice(), devInfo(info) {
    int nchannels = AudioHWInfo::getFormat().channelCount();
    channels = QVector<BufferFunction*>(nchannels);
    for (int i = 0; i < nchannels; i++) {
        channels[i] = new BufferFunction();
    }
}

AudioOut::AudioOut(QAudioDeviceInfo info)
    : QObject(QGuiApplication::instance()), Sink(AudioHWInfo::getFormat().channelCount()), devInfo(info) {
    dev = new QAudioOutput(devInfo, AudioHWInfo::getFormat());
    dev->setBufferSize(FRAMES_PER_PERIOD * channels.count() * BYTES_PER_SAMPLE);
    iodev = dev->start();
    maestro.registerSink(this);
    qDebug() << "plugin went with bufsz" << dev->bufferSize() << "period size" << dev->periodSize();
}

void AudioIn::start() {
    dev = new QAudioInput(devInfo, AudioHWInfo::getFormat());
    open(QIODevice::WriteOnly);
    dev->start(this);
}


int AudioOut::writeData(Sample *buf, long long count) {
    return iodev->write((char*)buf, count * BYTES_PER_SAMPLE) / BYTES_PER_SAMPLE;
}

AudioIn::~AudioIn() {
    dev->stop();
    delete dev;
    for (int i = 0; i < channels.count(); i++) {
        delete channels[i];
    }
}

AudioOut::~AudioOut() {
    dev->stop();
    delete dev;
}

qint64 AudioIn::writeData(const char *data, qint64 len) {
    Sample *samples = (Sample*)data;
    qint64 nsamples = len / BYTES_PER_SAMPLE;
    int idx = 0;
    int chan = 0;
    int nchannels = channels.count();
    while (idx < nsamples)
        channels[chan++ % nchannels]->put((samples[idx]+0.5) / 3276.75);
    return len;
}


