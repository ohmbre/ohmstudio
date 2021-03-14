#include "conductor.hpp"
#include "midi.hpp"
#include "sink.hpp"
#include "model.hpp"
#include "audio.hpp"
#include "dsp.hpp"

Conductor::Conductor() : ticks(1) {}

Conductor::~Conductor() {}

int Conductor::run(int argc, char **argv) {

    QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
    fmt.setSamples(2);
    QSurfaceFormat::setDefaultFormat(fmt);

    QGuiApplication app(argc, argv);
    AudioOut aOut;
    audioOut = &aOut;
    QQmlApplicationEngine engine;
    QJSValue jsGlobal = engine.globalObject();
    QQmlContext *context = engine.rootContext();
    jsGlobal.setProperty("global", jsGlobal);
    jsGlobal.setProperty("SymbolicFunction", engine.newQMetaObject(&SymbolicFunction::staticMetaObject));
    jsGlobal.setProperty("MIDIInFunction", engine.newQMetaObject(&MIDIInFunction::staticMetaObject));
    jsGlobal.setProperty("Fourier", engine.newQMetaObject(&Fourier::staticMetaObject));
    qmlRegisterType<Model>("ohm", 1, 0, "Model");
    qmlRegisterType<ShaderSink>("ohm", 1, 0, "ShaderSink");
    context->setContextProperty("AUDIO_OUT", audioOut);
    context->setContextProperty("MAESTRO", this);
    engine.load(QUrl("qrc:/app/OhmStudio.qml"));
    ShaderSink sink;
    app.exec();
    return 0;

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

    ma_decoder_config cfg = ma_decoder_config_init(ma_format_f32, 1, audioOut->sampleRate());
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


