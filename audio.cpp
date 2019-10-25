#include "audio.hpp"

QAudioFormat AudioOut::getFormat() {
    QAudioFormat format;
    format.setChannelCount(2);
    format.setSampleRate(FRAMES_PER_SEC);
    format.setSampleSize(8*BYTES_PER_SAMPLE);
    format.setSampleType(QAudioFormat::SignedInt);
    format.setCodec("audio/pcm");
    format.setByteOrder(QAudioFormat::LittleEndian);
    return format;
}

Q_INVOKABLE QStringList AudioOut::availableDevs() {
    QStringList names;
    freopen("/dev/null","w",stderr);
    foreach(QAudioDeviceInfo dev, QAudioDeviceInfo::availableDevices(QAudio::AudioOutput))
        if (dev.deviceName() != "pulse" && dev.isFormatSupported(getFormat()))
            names << dev.deviceName();
    freopen("/dev/tty","w",stderr);

    return names;
}

QAudioDeviceInfo AudioOut::devInfo(const QString &name) {
    QList<QAudioDeviceInfo> devs = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
    QList<QAudioDeviceInfo>::iterator dev;
    for (dev = devs.begin(); dev != devs.end(); ++dev)
        if (dev->deviceName() == name && dev->isFormatSupported(getFormat()))
            return *dev;
    qWarning() << "device doesnt exist or support format:" << name;
    return QAudioDeviceInfo();
}

Q_INVOKABLE qint64 AudioOut::channelCount() {
    return sinkChannelCount();
}

Q_INVOKABLE void AudioOut::setChannel(int i, QObject *function) {
    sinkSetChannel(i, function);
}

AudioOut::AudioOut()  : QObject(QGuiApplication::instance()), Sink(getFormat().channelCount()), dev(nullptr), iodev(nullptr) {}

void AudioOut::setDevice(const QString &name) {
    if (dev != nullptr) {
        dev->stop();
        delete dev;
    }
    dev = new QAudioOutput(devInfo(name), getFormat());
    dev->setBufferSize(FRAMES_PER_PERIOD * channels.count() * BYTES_PER_SAMPLE);
    iodev = dev->start();
    maestro.registerSink(this);
}

int AudioOut::writeData(Sample *buf, long long count) {
    return iodev->write((char*)buf, count * BYTES_PER_SAMPLE) / BYTES_PER_SAMPLE;
}

AudioOut::~AudioOut() {
    if (dev != nullptr) {
        dev->stop();
        delete dev;
    }
}



