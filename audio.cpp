#include "audio.h"


Audio::Audio() : initialized(false) {

    ma_context_init(NULL, 0, NULL, &ctx);
    reset();
}

Audio::~Audio() {
    if (initialized) ma_device_uninit(&dev);
    ma_context_uninit(&ctx);
}

   
Q_INVOKABLE QString Audio::outName() {
    return QString(dev.playback.name);
}

Q_INVOKABLE void Audio::setOutName(QString name) {
    QSettings settings("ohm");
    settings.setValue("outname", name);
    reset();
}

Q_INVOKABLE QString Audio::inName() {
    return QString(dev.capture.name);
}

Q_INVOKABLE void Audio::setInName(QString name) {
    QSettings settings("ohm");
    settings.setValue("inname", name);
    reset();
}


Q_INVOKABLE unsigned int Audio::sampleRate() {
    return dev.sampleRate;
}

Q_INVOKABLE void Audio::setSampleRate(unsigned int sampleRate) {
    QSettings settings("ohm");
    settings.setValue("sampleRate", sampleRate);
    reset();
}

Q_INVOKABLE unsigned int Audio::outChanCount() {
    return dev.playback.channels;
}

Q_INVOKABLE unsigned int Audio::inChanCount() {
    return dev.capture.channels;
}

Q_INVOKABLE unsigned int Audio::period() {
    return dev.playback.internalPeriodSizeInFrames;
}



void Audio::reset() {

    if (initialized) ma_device_uninit(&dev);

    QSettings settings("ohm");
    ma_device_config cfg = ma_device_config_init(ma_device_type_duplex);
    cfg.playback.format = cfg.capture.format = ma_format_s16;
    cfg.playback.channels = cfg.playback.channels = 0;
    cfg.sampleRate = settings.value("sampleRate", 48000).toInt();
    cfg.periodSizeInFrames = PERIOD;
    cfg.pUserData = this;

    if (settings.contains("outname"))
        cfg.playback.pDeviceID = getDevId(settings.value("outname").toString(), true);
    if (settings.contains("inname"))
        cfg.capture.pDeviceID = getDevId(settings.value("inname").toString(), false);


    cfg.dataCallback = [ ](ma_device *dev, void* pOutput, const void* pInput, ma_uint32 nframes) {
        Audio *me = (Audio*) dev->pUserData;
        
        unsigned int nOutChan = me->outChanCount();
        unsigned int nInChan = me->inChanCount();
        unsigned int nsinks = me->sinks.size();
        Sample *output = (Sample*) pOutput;
        Sample *input = (Sample*) pInput;
        double *sinkptr = me->sinkBuf;
        for (unsigned int f = 0; f < nframes; f++) {
            for (unsigned int c = 0; c < nInChan; c++)
                me->inChannels[c]->val = qBound(-10.,(double)(*input++)/3276.7, 10.);            
            for (unsigned int c = 0; c < nOutChan; c++)
                *output++ = qRound(qBound(-10.,(*me->outChannels[c])(),10.0)*3276.7);
            for (unsigned int s = 0; s < nsinks; s++)
                *sinkptr++ = qBound(-10., (*me->sinks[s]->func)(), 10.);
            maestro.ticks++;
        }
        for (unsigned int s = 0; s < nsinks; s++) {
            ma_rb *rb = &me->sinks[s]->ringbuf;
            int frames_to_write = nframes;
            sinkptr = me->sinkBuf + s;
            while (frames_to_write > 0) {
                void *chunk;
                size_t nbytes = frames_to_write * sizeof(double);
                ma_rb_acquire_write(rb, &nbytes, &chunk);
                int nv = nbytes / sizeof(double);
                double* vchunk = (double*) chunk;
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

    while (outChanCount() > outChannels.size()) {
        Func *func = new Func;
        outChannels.append(func);
    }
    
    while (inChanCount() > inChannels.size()) {
        MutableFunc *func = new MutableFunc();
        inChannels.append(func);
    }
   
    maestro.sym_s = sampleRate();
    maestro.sym_ms = maestro.sym_s/1000;
    maestro.sym_mins = sampleRate()*60;
    maestro.sym_hz = 2*M_PI/sampleRate();

    qDebug() << "audio output initialized";
    qDebug() << "   output device: " << outName();
    qDebug() << "   input device: " << inName();
    qDebug() << "   sample rate: " << sampleRate();
    qDebug() << "   num output channels: " << outChanCount();
    qDebug() << "   num input channels: " << inChanCount();
    qDebug() << "   period: " << period();


    ma_device_start(&dev);

    emit changed();
}

Q_INVOKABLE void Audio::pause() {
    if (initialized) ma_device_stop(&dev);
}

Q_INVOKABLE void Audio::resume() {
    if (initialized) ma_device_start(&dev);
}


Q_INVOKABLE void Audio::setOutChannel(int i, QObject *function) {
    if (i < 0 || i >= outChannels.size()) {
        qDebug() << "tried to set function for invalid channel" << i;
        return;
    }
    pause();
    if (function == nullptr) outChannels[i] = new Func;
    else outChannels[i] = qobject_cast<QFunc*>(function);
    resume();
}

Q_INVOKABLE QFunc* Audio::getInChannel(int i) {
    if (i < 0 || i >= inChannels.size()) {
        return new QFunc;
    }
    return inChannels[i];
}

Q_INVOKABLE void Audio::addSink(Sink *sink) {
    pause();
    if (!sinks.contains(sink))
        sinks.append(sink);
    resume();
}

Q_INVOKABLE void Audio::removeSink(Sink *sink) {
    pause();
    sinks.removeAll(sink);
    resume();
}



Q_INVOKABLE QStringList Audio::availableDevs(bool output) {
    QStringList devs;
    ma_device_info* infos;
    ma_uint32 count = 0;
    ma_result ret;
    if (output) ma_context_get_devices(&ctx, &infos, &count, NULL, NULL);
    else ma_context_get_devices(&ctx,  NULL, NULL, &infos, &count);
    for (ma_uint32 i = 0; i < count; i++)
        devs << infos[i].name;
    return devs;
}

ma_device_id * Audio::getDevId(QString name, bool output) {
    ma_device_info *infos;
    ma_uint32 count;
    if (output) ma_context_get_devices(&ctx, &infos, &count, NULL, NULL);
    else ma_context_get_devices(&ctx, NULL, NULL, &infos, &count);
    for (ma_uint32 i = 0; i < count; i++)
        if (QString(infos[i].name) == name)
            return &infos[i].id;
    return nullptr;    
}



