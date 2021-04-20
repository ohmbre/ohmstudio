#include <QSurfaceFormat>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QJSValue>
#include <QQmlContext>

#include <git2.h>

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
    
    dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir::setCurrent(dataDir);
    
       
    Audio aOut;
    audio = &aOut;
    
    QQmlApplicationEngine engine;
    engineP = &engine;
            
    QJSValue jsGlobal = engine.globalObject();
    QQmlContext *context = engine.rootContext();
    
    jsGlobal.setProperty("global", jsGlobal);
    jsGlobal.setProperty("SymbolicFunc", engine.newQMetaObject(&SymbolicFunc::staticMetaObject));
    jsGlobal.setProperty("MIDIInFunc", engine.newQMetaObject(&MIDIInFunc::staticMetaObject));
    jsGlobal.setProperty("MAESTRO", engine.toScriptValue<Conductor*>(this));
    jsGlobal.setProperty("AUDIO", engine.toScriptValue<Audio*>(audio));
    
    QUrl murl = QSettings("ohm").value("module_url", "https://github.com/ohmbre/ohmstudio-modules.git").toUrl();
    std::string moduleDir = (dataDir + "/modules").toStdString();
    git_repository *repo = NULL;
    git_libgit2_init();
    int ret = git_repository_open(&repo, moduleDir.c_str());
    if (ret < 0)
        ret = git_clone(&repo, murl.toString().toStdString().c_str(), moduleDir.c_str(), NULL);
    if (ret < 0)
        qDebug() << "Error cloning repo";
    QDir(dataDir).mkdir("patches");
    
    engine.load("qrc:/app/OhmStudio.qml");
    
    app.exec();
    audio->pause();
    
    return 0;
}



Q_INVOKABLE bool Conductor::write(const QString &relPath, const QString &content) {
    QString path = relPath;
    if (path.contains("://")) path = QUrl(path).toLocalFile();
    QFile f(path);
    if (!f.open(QIODevice::ReadWrite|QIODevice::Truncate|QIODevice::Text)) {
        qDebug() << "could not write to" << path;
        return false;
    }
    QTextStream out(&f);
    out << content << Qt::endl;
    f.close();

    return true;
}

Q_INVOKABLE QString Conductor::read(const QString &relpath) {
    QString path = relpath;
    if (path.contains("://")) path = QUrl(path).toLocalFile();
    QFile f(path);
    QString ret = f.open(QIODevice::ReadOnly|QIODevice::Text) ? QTextStream(&f).readAll() : "";
    return ret;
}

Q_INVOKABLE  QString Conductor::pwd() {
    return QDir::currentPath();
}

Q_INVOKABLE  QVariant Conductor::listDir(const QString &dname, const QString &match, const QString &base) {
    QString dpath = dname.startsWith(":/") ? dname : dataDir + "/" + dname;
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


QQmlComponent* Conductor::loadModule(QString name) {
    QString filename = name + ".qml";
    QString path = dataDir + "/modules/" + filename;
    QFile f(path);
    QByteArray data = f.open(QIODevice::ReadOnly) ? f.readAll() : QByteArray();
    QQmlComponent *c = new QQmlComponent(engineP, this);
    c->setData(data, QUrl("qrc:/app/"+filename));
    return c;
}

