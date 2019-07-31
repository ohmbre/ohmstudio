#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QDirIterator>
#include <QQmlContext>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QThread>
#include <QJSValue>
#include <QUrl>
#include <QIODevice>
#include <QAudioOutput>
#include <QJSEngine>
#include <QJSValueIterator>
#include <QDataStream>
#include <QWaitCondition>


#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <cerrno>

#define SAMPLE_RATE 48000
#define BYTES_PER_SAMPLE 2
#define NCHANNELS 2
#define BYTES_PER_FRAME 4
#define BUFSIZE 16384

class JSGlobal : public QObject {
Q_OBJECT
public:
    JSGlobal(QQmlContext *root) : QObject(root) {
     engine = root->engine();
    }
    Q_INVOKABLE void set(const QString &key, QJSValue val) {
        engine->globalObject().setProperty(key, val);
    }

private:
    QJSEngine *engine;
};

void logexception(QJSValue err) {
    qWarning() << err.property("name").toString() << "thrown in" <<  err.property("fileName").toString()
               << "at line" << err.property("lineNumber").toInt() << ":" << err.property("message").toString() << endl
               << "   Stack:" << err.property("stack").toString();
}

class SoundBackend : public QIODevice {
    Q_OBJECT
public:
    SoundBackend(QQmlContext *rootContext) : QIODevice(rootContext) {
        QJSEngine *engine = rootContext->engine();
        QJSValue global = engine->globalObject();

        ohm = global.property("ohm");
        streamOuts = ohm.property("streams").property("out");
        time = ohm.property("time");

        QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());
        QAudioFormat format;
        format.setSampleRate(SAMPLE_RATE);
        format.setChannelCount(NCHANNELS);
        format.setSampleSize(8*BYTES_PER_SAMPLE);
        format.setSampleType(QAudioFormat::SignedInt);
        format.setCodec("audio/pcm");
        format.setByteOrder(QAudioFormat::LittleEndian);
        if (!info.isFormatSupported(format)) {
            qWarning() << "hardware does not support requested pcm format";
            return;
        }

        setOpenMode(QIODevice::ReadWrite);
        outdev = new QAudioOutput(format, this);
        outdev->setBufferSize(BUFSIZE);
        outdev->start(this);
        if (outdev->bufferSize() != BUFSIZE)
        qWarning() << "using different buffer size!:" << outdev->bufferSize();
    }

    ~SoundBackend() {
        outdev->stop();
        delete outdev;
    }

    qint64 readData(char *data, qint64 maxSize) {
        if (maxSize < BUFSIZE) return 0;

        void *datamem = data;
        qint16 *buf = (qint16*)datamem;

        QJSValue streamOut1 = streamOuts.property(0);
        QJSValue streamOut2 = streamOuts.property(1);
        QJSValue timeIncFunc = time.property("inc");
	
        int nframes = BUFSIZE / BYTES_PER_FRAME;
        for (int i = 0; i < nframes; i++) {
            *buf++ = (qint16)round(streamOut1.toNumber()*3276.7);
            *buf++ = (qint16)round(streamOut2.toNumber()*3276.7);
            timeIncFunc.callWithInstance(time);
        }

        return BUFSIZE;
    }

    qint64 writeData(const char *, qint64 ) {

        return 0;
    }

private:
    QAudioOutput *outdev;
    QJSValue ohm;
    QJSValue streamOuts;
    QJSValue msgHandler;
    QJSValue time;

};

class FileIO : public QObject {
    Q_OBJECT

public:

    FileIO(QObject *parent) : QObject(parent) {}

    Q_INVOKABLE static bool write(const QString fname, const QString content) {
        QFile f(fname);
        if (!f.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text))
            return false;
        QTextStream out(&f);
        out << content << endl;
        f.close();
        QFile::setPermissions(fname, QFileDevice::ReadOwner | QFileDevice::WriteOwner
                              | QFileDevice::ReadGroup | QFileDevice::ReadOther);
        return true;
    }

    Q_INVOKABLE static QString read(const QString fname) {
        QFile f(fname);
        if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
            return "";
        QTextStream in(&f);
        QString ret = in.readAll();
        return ret;
    }

    Q_INVOKABLE static QVariant listDir(const QString dname, const QString match) {
        QDirIterator modIt(dname, QStringList() << match,
                           QDir::Files | QDir::AllDirs | QDir::NoDot |
                           QDir::NoDotDot, QDirIterator::FollowSymlinks);
        QStringList fnames,subnames;
        if (dname.contains('/')) subnames << dname + "/..";
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

protected:

};

#include "main.moc"

int main(int argc, char *argv[]) {

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QDirIterator qrcIt(":/app", QStringList() << "*.qml",
                       QDir::Files, QDirIterator::Subdirectories);
    while (qrcIt.hasNext()) {
        QString fname = qrcIt.next();
        if (fname.startsWith(":/app/modules/") || fname.startsWith(":/app/patches/")) {
            QDir cwd("");
            cwd.mkpath(fname.section('/',2,-2));
            QFile::copy(fname, fname.section('/',2,-1));
            QFile::setPermissions(fname.section('/',2,-1),
                                  QFileDevice::ReadOwner | QFileDevice::WriteOwner |
                                  QFileDevice::ReadGroup | QFileDevice::ReadOther);
        } else
            qmlRegisterType("qrc" + fname, "ohm", 1, 0,
                            fname.section('/',-1).chopped(4).toLatin1().data());
    }

    QDirIterator modIt("modules", QStringList() << "*.qml",
                       QDir::Files, QDirIterator::Subdirectories);
    while (modIt.hasNext()) {
        QString fname = modIt.next();
        qmlRegisterType(QUrl::fromLocalFile(fname), "modules", 1, 0,
                        fname.split('/').last().chopped(4).toLatin1().data());
    }

    QQmlContext *root = engine.rootContext();

    JSGlobal global(root);
    QJSValue jsGlobal = engine.newQObject(&global);
    engine.globalObject().setProperty("global", jsGlobal);

    FileIO fileIO(root);
    root->setContextProperty("FileIO", &fileIO);

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));
    SoundBackend soundBackend(root);

    return app.exec();
}
