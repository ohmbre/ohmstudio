#include <QSurfaceFormat>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QJSValue>
#include <QQmlContext>

#include "conductor.h"
#include "func.h"
#include "audio.h"
#include "midi.h"

#define MA_IMPLEMENTATION
#include "external/miniaudio.h"


Conductor::Conductor() : ticks(1) {}

Conductor::~Conductor() {}

int Conductor::run(int argc, char **argv) {

    QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
    fmt.setSamples(2);
    QSurfaceFormat::setDefaultFormat(fmt);

    QGuiApplication app(argc, argv);
    Audio aOut;
    audio = &aOut;
    QQmlApplicationEngine engine;
    engineP = &engine;
    QJSValue jsGlobal = engine.globalObject();
    QQmlContext *context = engine.rootContext();
    jsGlobal.setProperty("global", jsGlobal);
    jsGlobal.setProperty("SymbolicFunc", engine.newQMetaObject(&SymbolicFunc::staticMetaObject));
    jsGlobal.setProperty("MIDIInFunc", engine.newQMetaObject(&MIDIInFunc::staticMetaObject));
       
    context->setContextProperty("AUDIO", audio);
    context->setContextProperty("MAESTRO", this);
    engine.load("qrc:/app/OhmStudio.qml");
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
    QList<double> samples;

    ma_decoder_config cfg = ma_decoder_config_init(ma_format_f32, 1, audio->sampleRate());
    ma_decoder decoder;
    ma_result result;

    float buf[DECODE_CHUNK];

    result = ma_decoder_init_file(QDir::toNativeSeparators(path.toLocalFile()).toLatin1(), &cfg, &decoder);
    if (result != MA_SUCCESS) {
        qDebug() << "could not decode file" << path;
        return engineP->newArray(0);
    }
    
    double norm = 0;
    while (true) {
        ma_uint64 nframes = ma_decoder_read_pcm_frames(&decoder, buf, DECODE_CHUNK);
        for (ma_uint64 i = 0; i < nframes; i++) {
            if (abs(buf[i]) > norm) norm = abs(buf[i]);
            samples.append(buf[i]);
        }
        if (nframes != DECODE_CHUNK) break;
    }

    ma_decoder_uninit(&decoder);
    
    QJSValue ret = engineP->newArray(samples.size());
    for (int i = 0; i < samples.size(); i++)
        ret.setProperty(i, samples[i]/norm);
    return ret;
}

