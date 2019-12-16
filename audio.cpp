#include "audio.hpp"

static QAudioFormat getFormat() {
    QAudioFormat format;
    format.setChannelCount(2);
    format.setSampleRate(FRAMES_PER_SEC);
    format.setSampleSize(8*BYTES_PER_SAMPLE);
    format.setSampleType(QAudioFormat::SignedInt);
    format.setCodec("audio/pcm");
    format.setByteOrder(QAudioFormat::LittleEndian);
    return format;
}

QStringList availableDevsWithMode(QAudio::Mode mode) {
    QStringList names;
    freopen("/dev/null","w",stderr);
    foreach(QAudioDeviceInfo dev, QAudioDeviceInfo::availableDevices(mode))
        if (dev.deviceName() != "pulse" && dev.isFormatSupported(getFormat()))
            names << dev.deviceName();
    freopen("/dev/tty","w",stderr);
    return names;
}

QAudioDeviceInfo devInfo(QAudio::Mode mode, const QString &name) {
    QList<QAudioDeviceInfo> devs = QAudioDeviceInfo::availableDevices(mode);
    QList<QAudioDeviceInfo>::iterator dev;
    for (dev = devs.begin(); dev != devs.end(); ++dev)
        if (dev->deviceName() == name && dev->isFormatSupported(getFormat()))
            return *dev;
    qWarning() << "device doesnt exist or support format:" << name;
    return QAudioDeviceInfo();
}


/* --------- Output --------- */

Q_INVOKABLE AudioOut::AudioOut() :
    QObject(QGuiApplication::instance()), Sink(getFormat().channelCount()), dev(nullptr), iodev(nullptr) {}

Q_INVOKABLE QStringList AudioOut::availableDevs() {
    return availableDevsWithMode(QAudio::AudioOutput);
}

Q_INVOKABLE qint64 AudioOut::channelCount() {
    return sinkChannelCount();
}

Q_INVOKABLE void AudioOut::setChannel(int i, QObject *function) {
    sinkSetChannel(i, function);
}

void AudioOut::setDevice(const QString &name) {
    if (dev != nullptr) {
        dev->stop();
        delete dev;
    }
    dev = new QAudioOutput(devInfo(QAudio::AudioOutput, name), getFormat());
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


/* --------- Input --------- */


Q_INVOKABLE AudioIn::AudioIn() :
    QIODevice(), dev(nullptr), channels() {
    this->moveToThread(&maestro.thread);
}

Q_INVOKABLE QStringList AudioIn::availableDevs() {
    return availableDevsWithMode(QAudio::AudioInput);
}

Q_INVOKABLE qint64 AudioIn::channelCount() {
    return channels.count();
}

void AudioIn::setDevice(const QString &name) {
    if (dev != nullptr) {
        dev->stop();
        delete dev;
    }
    QAudioFormat fmt = getFormat();
    channels.resize(fmt.channelCount());
    for (int i = 0; i < channels.count(); i++) {
        channels[i] = new BufferFunction();
    }

    dev = new QAudioInput(devInfo(QAudio::AudioInput, name), getFormat());
    dev->setBufferSize(FRAMES_PER_PERIOD * channels.count() * BYTES_PER_SAMPLE);
    open(QIODevice::WriteOnly);
    dev->start(this);
}

qint64 AudioIn::writeData(const char *data, qint64 len) {
    Sample *samples = (Sample*)data;
    qint64 nsamples = len / BYTES_PER_SAMPLE;
    int idx = 0;
    int chan = 0;
    int nchannels = channels.count();

    for (int i = 0; i < nchannels; i++)
        channels[i]->trim();

    while (idx < nsamples)
        channels[chan++ % nchannels]->put(samples[idx++] / 3276.7);

    return len;
}

Q_INVOKABLE Function* AudioIn::getChannel(int i) {
    return channels[i];
}

AudioIn::~AudioIn() {
    if (dev != nullptr) {
        dev->stop();
        dev->deleteLater();
    }
    for (int i = 0; i < channels.count(); i++)
        if (channels[i] != nullptr)
            channels[i]->deleteLater();
}
