#include "audio.hpp"

#define MINIAUDIO_IMPLEMENTATION
#include "external/miniaudio.h"

AudioOut::AudioOut() : initialized(false) {
    ma_context_init(NULL, 0, NULL, &ctx);
    reset();
}

AudioOut::~AudioOut() {
    if (initialized) ma_device_uninit(&dev);
    ma_context_uninit(&ctx);
}

   
Q_INVOKABLE QString AudioOut::name() {
    return QString(dev.playback.name);
}

Q_INVOKABLE void AudioOut::setName(QString name) {
    QSettings settings("ohm");
    settings.setValue("name", name);
    reset();
}

Q_INVOKABLE unsigned int AudioOut::sampleRate() {
    return dev.sampleRate;
}

Q_INVOKABLE void AudioOut::setSampleRate(unsigned int sampleRate) {
    QSettings settings("ohm");
    settings.setValue("sampleRate", sampleRate);
    reset();
}

Q_INVOKABLE unsigned int AudioOut::chCount() {
    return dev.playback.channels;
}
Q_INVOKABLE unsigned int AudioOut::period() {
    return dev.playback.internalPeriodSizeInFrames;
}

void AudioOut::reset() {

    if (initialized) ma_device_uninit(&dev);

    QSettings settings("ohm");
    ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
    cfg.playback.format = ma_format_s16;
    cfg.playback.channels = 0;
    cfg.sampleRate = settings.value("sampleRate", 48000).toInt();
    cfg.periodSizeInFrames = PERIOD;
    cfg.pUserData = this;

    if (settings.contains("name")) {
        QString name = settings.value("name").toString();
        ma_device_info* infos;
        ma_uint32 count;
        ma_context_get_devices(&ctx, &infos, &count, NULL, NULL);
        ma_device_id *devId = nullptr;
        for (ma_uint32 i = 0; i < count; i++)
            if (QString(infos[i].name) == name) {
                devId = &infos[i].id;
                break;
            }
        if (devId != nullptr)
            cfg.playback.pDeviceID = devId;
    }

    cfg.dataCallback = [ ](ma_device *dev, void* pOutput, const void*, ma_uint32 nframes) {
        AudioOut *me = (AudioOut*) dev->pUserData;
        
        unsigned int nchan = me->chCount();
        unsigned int nsinks = me->sinks.size();
        Sample *output = (Sample*) pOutput;
        V *sinkptr = me->sinkBuf;
        for (unsigned int f = 0; f < nframes; f++) {
            for (unsigned int c = 0; c < nchan; c++)
                *output++ = qRound(qBound(-10.0,(*me->channels[c])(),10.0)*3276.7);
            for (unsigned int s = 0; s < nsinks; s++)
                *sinkptr++ = qBound(-10.0, (*me->sinks[s]->func)(), 10.0);
            maestro.ticks++;
        }
        for (unsigned int s = 0; s < nsinks; s++) {
            ma_rb *rb = &me->sinks[s]->ringbuf;
            int frames_to_write = nframes;
            sinkptr = me->sinkBuf + s;
            while (frames_to_write > 0) {
                void *chunk;
                size_t nbytes = frames_to_write * sizeof(V);
                ma_rb_acquire_write(rb, &nbytes, &chunk);
                int nv = nbytes / sizeof(V);
                V* vchunk = (V*) chunk;
                for (int f = 0; f < nv; f++) {
                    vchunk[f] = *sinkptr;
                    sinkptr += nsinks;
                }
                ma_rb_commit_write(rb, nbytes, chunk);
                frames_to_write -= nv;
                if (nbytes == 0) frames_to_write = 0;
            }
        }
    };

    if (ma_device_init(&ctx, &cfg, &dev) != MA_SUCCESS) {
        qDebug() << "couldn't initialize audio output device";
        return;
    }
    
    initialized = true;

    while (chCount() > channels.size()) {
        Function *func = new NullFunction;
        channels.append(func);
    }
   
    maestro.sym_s = sampleRate();
    maestro.sym_ms = maestro.sym_s/1000;
    maestro.sym_mins = sampleRate()*60;
    maestro.sym_hz = 2*M_PI/sampleRate();

    qDebug() << "audio output initialized";
    qDebug() << "   device: " << name();
    qDebug() << "   sample rate: " << sampleRate();
    qDebug() << "   num channels: " << chCount();
    qDebug() << "   period: " << period();


    ma_device_start(&dev);

    emit changed();
}

Q_INVOKABLE void AudioOut::pause() {
    if (initialized) ma_device_stop(&dev);
}

Q_INVOKABLE void AudioOut::resume() {
    if (initialized) ma_device_start(&dev);
}


Q_INVOKABLE void AudioOut::setChannel(int i, QObject *function) {
    if (i < 0 || i >= channels.size()) {
        qDebug() << "tried to set function for invalid channel" << i;
        return;
    }
    pause();
    if (function == nullptr) channels[i] = new NullFunction;
    else channels[i] = qobject_cast<Function*>(function);
    resume();    
    
}

Q_INVOKABLE void AudioOut::addSink(Sink *sink) {
    pause();
    if (!sinks.contains(sink))
        sinks.append(sink);
    resume();
}

Q_INVOKABLE void AudioOut::removeSink(Sink *sink) {
    pause();
    sinks.removeAll(sink);
    resume();
}



Q_INVOKABLE QStringList AudioOut::availableDevs() {
    QStringList devs;
    ma_device_info* infos;
    ma_uint32 count;
    if (ma_context_get_devices(&ctx, &infos, &count, NULL, NULL) != MA_SUCCESS) {
        qDebug() << "could not get audio output devices list";
        return devs;
    }

    for (ma_uint32 i = 0; i < count; i++)
        devs << infos[i].name;

    return devs;
}

/*
Q_INVOKABLE AudioIn::AudioIn() : QIODevice(), channels() {
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
    //return devList.keys();
    return QStringList();
}


bool AudioIn::setDevice(const QString &) {
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

qint64 AudioIn::writeData(const char *, qint64 ) {

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
    return 0;
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
}*/
