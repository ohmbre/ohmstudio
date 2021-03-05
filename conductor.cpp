#include "conductor.hpp"
#include "midi.hpp"
#include "audio.hpp"
#include "dsp.hpp"

Conductor::Conductor() : ticks(0), mutex() {}

Conductor::~Conductor() {}

int Conductor::run(int argc, char **argv) {

    QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
    fmt.setSamples(2);
    QSurfaceFormat::setDefaultFormat(fmt);

    qapp = new QGuiApplication(argc, argv);
    settings = new QSettings("ohm");
    ma_context_init(NULL, 0, NULL, &audioContext);
    for (unsigned int c = 0; c < MAX_CHANNELS; c++)
        channelMap[c] = nullptr;
    resetOutput();

    engine = new QQmlApplicationEngine;
    gui = engine->globalObject();
    gui.setProperty("global", gui);
    gui.setProperty("SymbolicFunction", engine->newQMetaObject(&SymbolicFunction::staticMetaObject));
    gui.setProperty("MIDIInFunction", engine->newQMetaObject(&MIDIInFunction::staticMetaObject));
    gui.setProperty("AudioIn", engine->newQMetaObject(&AudioIn::staticMetaObject));
    gui.setProperty("Fourier", engine->newQMetaObject(&Fourier::staticMetaObject));
    engine->rootContext()->setContextProperty("maestro", this);
    engine->load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));

    qDebug() << "main thread:" <<  QThread::currentThreadId();
    qapp->exec();

    ma_device_stop(&outDev);
    mutex.lock();
    ma_device_uninit(&outDev);
    ma_context_uninit(&audioContext);
    mutex.unlock();

    delete engine;
    delete settings;
    delete qapp;

    return 0;

}


Q_INVOKABLE void Conductor::setChannel(int i, QObject *function) {
    if (i < 0 || i >= MAX_CHANNELS) {
        qDebug() << "tried to set function for invalid channel" << i;
        return;
    }
    mutex.lock();
    if (function == nullptr) channelMap[i] = nullptr;
    else channelMap[i] = qobject_cast<Function*>(function);
    mutex.unlock();
}

void Conductor::resetOutput() {


    ma_device_stop(&outDev);
    mutex.lock();
    ma_device_uninit(&outDev);
    mutex.unlock();

    ma_device_config cfg = ma_device_config_init(ma_device_type_playback);
    cfg.playback.format = ma_format_s16;
    cfg.playback.channels = 0;
    cfg.sampleRate = settings->value("sampleRate", 48000).toInt();
    cfg.periodSizeInFrames = PERIOD_ASK;
    cfg.pUserData = this;

    if (settings->contains("outputName")) {
        QString name = settings->value("outputName").toString();
        ma_device_info* infos;
        ma_uint32 count;
        ma_context_get_devices(&audioContext, &infos, &count, NULL, NULL);
        ma_device_id *devId = nullptr;
        for (ma_uint32 i = 0; i < count; i++)
            if (QString(infos[i].name) == name) {
                devId = &infos[i].id;
                break;
            }
        if (devId != nullptr)
            cfg.playback.pDeviceID = devId;
    }

    cfg.dataCallback = [](ma_device *dev, void* pOutput, const void*, ma_uint32 nframes) {
        Conductor *me = (Conductor*) dev->pUserData;
        if (me->ticks == 0)
            qDebug() << "audio thread:" <<  QThread::currentThreadId();
        me->mutex.lock();
        unsigned int nchan = me->outputChCount();
        Function **channelMap = (Function**) me->channelMap;
        Sample *samples = (Sample*) pOutput;
        Function *func;
        unsigned int pos = 0;
        for (unsigned int f = 0; f < nframes; f++) {
            for (unsigned int c = 0; c < nchan; c++) {
                func = channelMap[c];
                samples[pos++] = func == nullptr ? 0 : qRound(qBound(-10.0,(*func)(),10.0)*3276.7);
            }
            me->ticks++;
        }
        me->mutex.unlock();
    };

    if (ma_device_init(&audioContext, &cfg, &outDev) != MA_SUCCESS) {
        qDebug() << "couldn't initialize audio output device";
        return;
    }

    sym_s = sampleRate();
    sym_ms = sym_s/1000;
    sym_mins = sampleRate()*60;
    sym_hz = 2*M_PI/sampleRate();

    ma_device_start(&outDev);
    qDebug() << "audio output initialized";
    qDebug() << "   device: " << outputName();
    qDebug() << "   sample rate: " << sampleRate();
    qDebug() << "   num channels: " << outputChCount();
    qDebug() << "   period: " << period();

    emit outputChanged();

}

Q_INVOKABLE QStringList Conductor::availableDevs() {
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

Q_INVOKABLE bool Conductor::write(const QString &relPath, const QString &content) {
    QString relDir = relPath.section('/',0,-2);
    QString fileName = relPath.section('/',-1);
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QString dirPath = QDir::cleanPath(dataDir + "/" + relDir);
    QDir::root().mkpath(dirPath);
    QString path = dirPath + "/" + fileName;
    QFile f(path);
    if (!f.open(QIODevice::ReadWrite|QIODevice::Truncate|QIODevice::Text))
        return false;
    QTextStream out(&f);
    out << content << Qt::endl;
    f.close();
    QFile::setPermissions(path, QFileDevice::ReadOwner|QFileDevice::WriteOwner|QFileDevice::ReadGroup|QFileDevice::ReadOther);
    return true;
}

Q_INVOKABLE  QString Conductor::read(const QString &relpath) {
    QString path = relpath.startsWith(":/") || relpath.startsWith("/") ? relpath
      : QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/" + relpath;
    QFile f(path);
    QString ret = f.open(QIODevice::ReadOnly|QIODevice::Text) ? QTextStream(&f).readAll() : "";
    return ret;
}

Q_INVOKABLE  QString Conductor::pwd() {
    return QDir::currentPath();
}

Q_INVOKABLE  QVariant Conductor::listDir(const QString &dname, const QString &match, const QString &base) {
    QString dpath = dname.startsWith(":/") ? dname : QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/" + dname;
    QDirIterator modIt(dpath,QStringList()<<match,QDir::Files|QDir::NoDot|QDir::NoDotDot|QDir::AllDirs,QDirIterator::FollowSymlinks);
    QStringList fnames,subnames;
    if (dname != base) subnames << dname + "/..";
    while (modIt.hasNext()) {
        QString fname = modIt.next();
        QFileInfo finfo(fname);
        if (finfo.isDir())
            subnames << fname;
        else fnames << fname;
    }
    for (QString name : fnames)
        subnames << name;
    return QVariant::fromValue(subnames);
}



#define DECODE_CHUNK 4096

Q_INVOKABLE QJSValue Conductor::samplesFromFile(QUrl path) {
    QList<V> samples;

    ma_decoder_config cfg = ma_decoder_config_init(ma_format_f32, 1, maestro.sampleRate());
    ma_decoder decoder;
    ma_result result;

    float buf[DECODE_CHUNK];

    result = ma_decoder_init_file(QDir::toNativeSeparators(path.toLocalFile()).toLatin1(), &cfg, &decoder);
    if (result != MA_SUCCESS) {
        qDebug() << "could not decode file" << path;
        return qmlEngine(this)->newArray(0);
    }

    while (true) {
        ma_uint64 nframes = ma_decoder_read_pcm_frames(&decoder, buf, DECODE_CHUNK);
        for (ma_uint64 i = 0; i < nframes; i++)
            samples.append(buf[i]);
        if (nframes != DECODE_CHUNK) break;
    }

    ma_decoder_uninit(&decoder);

    QJSValue ret = qmlEngine(this)->newArray(samples.size());
    for (int i = 0; i < samples.size(); i++)
        ret.setProperty(i, samples[i]*10);
    return ret;
}

