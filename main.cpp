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

void logexception(QJSValue err) {
    qWarning() << err.property("name").toString() << "thrown in" <<  err.property("fileName").toString()
               << "at line" << err.property("lineNumber").toInt() << ":" << err.property("message").toString() << endl
               << "   Stack:" << err.property("stack").toString();
}

class SoundBackend : public QIODevice {
    Q_OBJECT

public slots:

    void setup() {
        buffer = nullptr;

        jsEngine = new QJSEngine();
        jsEngine->installExtensions(QJSEngine::AllExtensions);
        QJSValue module = jsEngine->importModule(":/app/engine/ohm.mjs");
        if (module.isError()) {
            logexception(module);
            return;
        }
        QJSValue ohm = module.property("OhmEngine").call();
        if (ohm.isError()) {
            logexception(ohm);
            return;
        }
        streamOuts = ohm.property("streams").property("out");
        msgHandler = ohm.property("handle");
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
        outdev->setBufferSize(8192*2);
        buffer = new QByteArray(outdev->bufferSize(), 0);
        full = false;
        connect(this, &SoundBackend::bufferEmptied, this, &SoundBackend::fillBuffer);
        fillBuffer();
        outdev->start(this);
        qWarning() << "actual buffer size" << outdev->bufferSize();
    }

    void handleMsg(const QString &msg) {
        QJSValueList args;
        args << msg;
        QJSValue ret = msgHandler.call(args);
        if (ret.isError())
            logexception(ret);
    }

    void teardown() {
        outdev->stop();
        delete jsEngine;
        delete outdev;
        deleteLater();
    }

    void fillBuffer() {
        mutex.lock();
        if (full)
            condEmpty.wait(&mutex);
        mutex.unlock();

        void *v = buffer->data();
        qint16 *data = (qint16*)v;

        QJSValue streamOut1 = streamOuts.property(0);
        QJSValue streamOut2 = streamOuts.property(1);
        int t = time.property("val").toInt();

        int nframes = buffer->size() / BYTES_PER_FRAME;
        for (int i = 0; i < nframes; i++,t++) {
            *data++ = (qint16)round(streamOut1.toNumber()*3276.7);
            *data++ = (qint16)round(streamOut2.toNumber()*3276.7);
            time.setProperty("val", QJSValue(t));
        }

        mutex.lock();
        full = true;
        condFull.wakeAll();
        mutex.unlock();

        emit readyRead();
    }

    qint64 readData(char *data, qint64 maxSize) {
        if (maxSize < buffer->size()) return 0;

        mutex.lock();
        if (!full)
            condFull.wait(&mutex);
        mutex.unlock();

        void *src = buffer->data();
        memcpy(data, src, (size_t)buffer->size());

        mutex.lock();
        full = false;
        condEmpty.wakeAll();
        mutex.unlock();

        emit bufferEmptied();
        return buffer->size();
    }

    qint64 writeData(const char *, qint64 ) {
        return 0;
    }

signals:
    void bufferEmptied();

private:
    QJSEngine *jsEngine;
    QByteArray *buffer;
    QAudioOutput *outdev;
    QMutex mutex;
    QWaitCondition condFull;
    QWaitCondition condEmpty;
    bool full;
    QJSValue streamOuts;
    QJSValue msgHandler;
    QJSValue time;

};

class SoundEngine : public QObject {
    Q_OBJECT
    QThread thread;

public:
    SoundEngine() {
        backend = new SoundBackend();
        backend->moveToThread(&thread);
        connect(&thread, &QThread::started, backend, &SoundBackend::setup);
        connect(&thread, &QThread::finished, backend, &SoundBackend::teardown);
        connect(this, &SoundEngine::sendMsg, backend, &SoundBackend::handleMsg);
        thread.start();
    }
    ~SoundEngine(){
        thread.quit();
        thread.wait();
    }
signals:
    void sendMsg(const QString &msg);

private:
    SoundBackend *backend;
};

class FileIO : public QObject {
    Q_OBJECT

public:

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

    SoundEngine *soundEngine = new SoundEngine();
    FileIO *fileIO = new FileIO();

    engine.rootContext()->setContextProperty("FileIO", fileIO);
    engine.rootContext()->setContextProperty("SoundEngine", soundEngine);

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));


    return app.exec();
}
