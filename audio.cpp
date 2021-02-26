#include "audio.hpp"

#define MINIAUDIO_IMPLEMENTATION
#include "external/miniaudio.h"

Q_INVOKABLE AudioIn::AudioIn() : QIODevice(), channels() {
    /*foreach(QAudioDeviceInfo devInfo, QAudioDeviceInfo::availableDevices(QAudio::AudioInput)) {
        int verifiedChans = preCheckFormat(&devInfo);
        if (verifiedChans > 0) {
            QAudioFormat fmt;
            setupFormat(&fmt);
            fmt.setChannelCount(verifiedChans);
            QString identifier = devInfo.realm() + "|" + QString::number(verifiedChans) + "ch|" + devInfo.deviceName();
            devList[identifier] = { devInfo, fmt };
        }
    }*/
}

Q_INVOKABLE QStringList AudioIn::availableDevs() {
    //return devList.keys();
    return QStringList();
}


bool AudioIn::setDevice(const QString &) {
    /*if (dev != nullptr) {
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
    dev->start(this);*/
    return true;
}

qint64 AudioIn::writeData(const char *, qint64 ) {

   /* Sample *samples = (Sample*)data;
    qint64 nsamples = len / sizeof(Sample);
    int idx = 0;
    int chan = 0;
    int nchannels = channels.count();

    for (int i = 0; i < nchannels; i++)
        channels[i]->trim();

    while (idx < nsamples)
        channels[chan++ % nchannels]->put(samples[idx++] / 3276.7);

    return len;*/
    return 0;
}

Q_INVOKABLE Function* AudioIn::getChannel(int i) {
    return channels[i];
}

AudioIn::~AudioIn() {
    /*if (dev != nullptr) {
        dev->stop();
        dev->deleteLater();
    }
    for (int i = 0; i < channels.count(); i++)
        if (channels[i] != nullptr)
            channels[i]->deleteLater();*/
}
