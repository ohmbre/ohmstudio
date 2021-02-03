#include "audio.hpp"

#define MINIAUDIO_IMPLEMENTATION
#include "external/miniaudio.h"


ma_context audioContext;

void createAudioContext() {
    ma_context_init(NULL, 0, NULL, &audioContext);
}

void destroyAudioContext() {
    ma_context_uninit(&audioContext);
}


/* --------- Output --------- */

Q_INVOKABLE AudioOut::AudioOut() :
    QObject(QGuiApplication::instance()), Sink(0), initialized(false) {}

Q_INVOKABLE QStringList AudioOut::availableDevs() {
    QStringList devs;
    ma_device_info* infos;
    ma_uint32 count;
    if (ma_context_get_devices(&audioContext, &infos, &count, NULL, NULL) != MA_SUCCESS) {
        qDebug() << "could not get audio output devices list";
        return devs;
    }

    for (ma_uint32 i = 0; i < count; i++)
        devs << infos[i].name;

    return devs;
}

Q_INVOKABLE void AudioOut::setChannel(int i, QObject *function) {
    sinkSetChannel(i, function);
}

bool AudioOut::setDevice(const QString &name) {
    maestro.deregisterSink(this);
    if (initialized) {
        ma_device_uninit(&dev);
        ma_rb_uninit(&ringOut);
        initialized = false;
    }

    ma_device_info* infos;
    ma_uint32 count;
    if (ma_context_get_devices(&audioContext, &infos, &count, NULL, NULL) != MA_SUCCESS) {
        qDebug() << "couldnt enumerate audio output backend devices";
        return false;
    }

    ma_device_id *devId = nullptr;
    for (ma_uint32 i = 0; i < count; i++)
        if (QString(infos[i].name) == name) {
            devId = &infos[i].id;
            break;
        }
    if (devId == nullptr) return false;

    ma_device_info info;
    if (ma_context_get_device_info(&audioContext, ma_device_type_playback, devId, ma_share_mode_shared, &info) != MA_SUCCESS) {
        qDebug() << "couldnt query audio output device info";
        return false;
    }

    ma_device_config config = ma_device_config_init(ma_device_type_playback);
    config.playback.pDeviceID = devId;
    config.playback.format = ma_format_s16;
    config.playback.channels = info.maxChannels;
    config.sampleRate = FRAMES_PER_SEC;
    config.dataCallback = [](ma_device* dev, void* pOutput, const void*, ma_uint32 nframes) {
        ma_rb *ringOut = (ma_rb *) dev->pUserData;
        void *ringPtr;
        //QStringList chunks;
        size_t toWrite = nframes * sizeof(Sample) * dev->playback.channels;
        while (toWrite > 0) {
            size_t nbytes = toWrite;
            ma_rb_acquire_read(ringOut, &nbytes, &ringPtr);
            {
                memcpy(pOutput, ringPtr, nbytes);
            }
            ma_rb_commit_read(ringOut, nbytes, ringPtr);
            //chunks << QString::number(nbytes);
            if (nbytes == 0) break;
            toWrite -= nbytes;
        }
        //qDebug() << "ringOut->dev target =" << sizeof(Sample) * dev->playback.channels * nframes << " chunks =" << chunks.join(',') << " leftover =" << toWrite;
    };
    config.pUserData = &ringOut;

    qDebug() << "max channels: " << info.maxChannels;
    ma_rb_init(sizeof(Sample) * info.maxChannels * PERIOD * 16, nullptr, nullptr, &ringOut);
    if (ma_device_init(&audioContext, &config, &dev) != MA_SUCCESS) {
        qDebug() << "couldnt initialize audio output device";
        return false;
    }
    initialized = true;
    setChannelCount(config.playback.channels);
    maestro.registerSink(this);
    ma_device_start(&dev);
    return true;
}

void AudioOut::flush() {

    void *ringPtr;

    //QStringList chunks;
    size_t toWrite = sizeof(Sample) * nchan() * PERIOD;
    while (toWrite > 0) {
        size_t nbytes = toWrite;
        ma_rb_acquire_write(&ringOut, &nbytes, &ringPtr);
        {
            memcpy(ringPtr, buf, nbytes);
        }
        ma_rb_commit_write(&ringOut, nbytes, ringPtr);
        //chunks << QString::number(nbytes);
        if (nbytes == 0) break;
        toWrite -= nbytes;
    }
    //qDebug() << "buf->ringOut target =" << sizeof(Sample) * nchan() * PERIOD << " chunks =" << chunks.join(',') << " leftover =" << toWrite;

}

AudioOut::~AudioOut() {
    maestro.deregisterSink(this);
    if (initialized) {
        ma_rb_uninit(&ringOut);
        ma_device_uninit(&dev);
        initialized = false;
    }
}


/* --------- Input --------- */


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


bool AudioIn::setDevice(const QString &name) {
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

qint64 AudioIn::writeData(const char *data, qint64 len) {

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

void decodeSamples(QString path, QList<V> *samples) {

    ma_decoder_config cfg = ma_decoder_config_init(ma_format_f32, 1, FRAMES_PER_SEC);
    ma_decoder decoder;
    ma_result result;
    float buf[PERIOD];

    result = ma_decoder_init_file(path.toLatin1(), &cfg, &decoder);
    if (result != MA_SUCCESS) {
        qDebug() << "could not decode file" << path;
        return;
    }

    while (true) {
        ma_uint64 nframes = ma_decoder_read_pcm_frames(&decoder, buf, PERIOD);
        for (ma_uint64 i = 0; i < nframes; i++)
            samples->append(buf[i]);
        if (nframes != PERIOD) break;
    }

    ma_decoder_uninit(&decoder);

}
