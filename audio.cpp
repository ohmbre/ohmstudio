#include "audio.hpp"

void setupFormat(QAudioFormat *fmt) {
    fmt->setSampleRate(FRAMES_PER_SEC);
    fmt->setSampleSize(8*sizeof(Sample));
    fmt->setSampleType(QAudioFormat::SignedInt);
    fmt->setCodec("audio/pcm");
    fmt->setByteOrder(QAudioFormat::LittleEndian);
}

int preCheckFormat(QAudioDeviceInfo *devInfo) {
    QAudioFormat fmt;
    setupFormat(&fmt);
    int prefChan = devInfo->preferredFormat().channelCount();
    fmt.setChannelCount(prefChan);
    if (devInfo->isFormatSupported(fmt))
        return prefChan;
    int maxChan = 0;
    foreach (int ch, devInfo->supportedChannelCounts()) {
        fmt.setChannelCount(ch);
        if (devInfo->isFormatSupported(fmt))
            maxChan = qMax(maxChan, ch);
    }
    return maxChan;
}


/* --------- Output --------- */

Q_INVOKABLE AudioOut::AudioOut() :
    QObject(QGuiApplication::instance()), Sink(0), dev(nullptr), iodev(nullptr), devList()
{
    foreach(QAudioDeviceInfo devInfo, QAudioDeviceInfo::availableDevices(QAudio::AudioOutput)) {
        int verifiedChans = preCheckFormat(&devInfo);
        if (verifiedChans > 0) {
            QAudioFormat fmt;
            setupFormat(&fmt);
            fmt.setChannelCount(verifiedChans);
            QString identifier = devInfo.realm() + "|" + QString::number(verifiedChans) + "ch|" + devInfo.deviceName();
            devList[identifier] = { devInfo, fmt };
        }
    }
}

Q_INVOKABLE QStringList AudioOut::availableDevs() {
    return devList.keys();
}


Q_INVOKABLE void AudioOut::setChannel(int i, QObject *function) {
    sinkSetChannel(i, function);
}

bool AudioOut::setDevice(const QString &name) {
    maestro.deregisterSink(this);
    if (dev != nullptr) {
        dev->stop();
        delete dev;
    }
    if (!devList.contains(name)) return false;
    dev = new QAudioOutput(devList[name].first, devList[name].second);
    if (dev->error() != QAudio::NoError) {
        qDebug() << "Audio output error" << dev->error();
        return false;
    }
    iodev = dev->start();
    setChannelCount(devList[name].second.channelCount());
    minPeriod = dev->periodSize() / nchan() / sizeof(Sample);
    maxPeriod = dev->bufferSize() / nchan() / sizeof(Sample);
    //long samplesInBuf = dev->bufferSize() / sizeof(Sample);
    //Sample *zerobuf = new Sample[samplesInBuf];
    //for (long i = 0; i < samplesInBuf; i++)
    //    zerobuf[i] = 0;
    //iodev->write((char*)zerobuf, dev->bufferSize());
    maestro.registerSink(this);
    return true;
}

void AudioOut::flush() {
    if (iodev && iodev->isWritable()) {
        QAudio::State s = dev->state();
        QAudio::Error e = dev->error();
        if (e == QAudio::NoError && (s == QAudio::IdleState || s == QAudio::ActiveState)) {
            iodev->write((char*)buf, maestro.period * nchan() * sizeof(Sample));
        } else if (e == QAudio::UnderrunError) {


        }
    }
}

AudioOut::~AudioOut() {
    maestro.deregisterSink(this);
    if (dev != nullptr) {
        dev->stop();
        delete dev;
    }
}


/* --------- Input --------- */


Q_INVOKABLE AudioIn::AudioIn() : QIODevice(), dev(nullptr), channels(), devList(){
    foreach(QAudioDeviceInfo devInfo, QAudioDeviceInfo::availableDevices(QAudio::AudioInput)) {
        int verifiedChans = preCheckFormat(&devInfo);
        if (verifiedChans > 0) {
            QAudioFormat fmt;
            setupFormat(&fmt);
            fmt.setChannelCount(verifiedChans);
            QString identifier = devInfo.realm() + "|" + QString::number(verifiedChans) + "ch|" + devInfo.deviceName();
            devList[identifier] = { devInfo, fmt };
        }
    }
}

Q_INVOKABLE QStringList AudioIn::availableDevs() {
    return devList.keys();
}


bool AudioIn::setDevice(const QString &name) {
    if (dev != nullptr) {
        dev->stop();
        delete dev;
    }
    if (!devList.contains(name)) return false;
    channels.resize(devList[name].second.channelCount());
    for (int i = 0; i < channels.count(); i++) {
        channels[i] = new BufferFunction();
    }
    dev = new QAudioInput(devList[name].first, devList[name].second);
    open(QIODevice::WriteOnly);
    dev->start(this);
    return true;
}

qint64 AudioIn::writeData(const char *data, qint64 len) {
    Sample *samples = (Sample*)data;
    qint64 nsamples = len / sizeof(Sample);
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
