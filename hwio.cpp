#include <QAudioOutput>
#include <QAudioInput>
#include <QAudioDeviceInfo>
#include <QFile>
#include <QDir>
#include <QDirIterator>

#include "common.h"
#include "external/RtMidi.h"

constexpr auto RD = QIODevice::ReadOnly|QIODevice::Text;
constexpr auto WR = QIODevice::ReadWrite|QIODevice::Truncate|QIODevice::Text;
constexpr auto PERM = QFileDevice::ReadOwner|QFileDevice::WriteOwner|QFileDevice::ReadGroup|QFileDevice::ReadOther;


class AudioIO : public QObject {
    Q_OBJECT
    QScopedPointer<QAudioOutput> audioOut;
    QScopedPointer<QAudioInput> audioIn;

public slots:
     void start(const QAudioDeviceInfo &outDev, const QAudioDeviceInfo &inDev, const QAudioFormat &format)  {
        if (!audioOut.isNull()) audioOut->stop();
        if (!audioIn.isNull()) audioIn->stop();
        QIODevice *outBuf = nullptr, *inBuf = nullptr;
        if (!outDev.isNull()) {
            audioOut.reset(new QAudioOutput(outDev,format,this));
            audioOut->setBufferSize(BYTES_PER_PERIOD);
            outBuf = audioOut->start();
        }
        if (!inDev.isNull()) {
            audioIn.reset(new QAudioInput(inDev,format,this));
            audioIn->setBufferSize(BYTES_PER_PERIOD);
            inBuf = audioIn->start();
        }
        while (outBuf != nullptr || inBuf != nullptr) {
            ioloop(outBuf,inBuf);
            if (audioOut.isNull() || (audioOut->state() == QAudio::StoppedState)) outBuf = nullptr;
            if (audioIn.isNull() || (audioIn->state() == QAudio::StoppedState)) inBuf = nullptr;
        }
        qDebug() << "audio stop/error: state =" << audioOut->state() << ", error =" << audioOut->error();
    }

public:

    ~AudioIO() {
        if (!audioOut.isNull()) audioOut->stop();
        if (!audioIn.isNull()) audioIn->stop();
    }

};

class HWIO : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString outName READ getOutName WRITE setOutName NOTIFY outNameChanged)
    QString outName;
    QString inName;
    QThread audioThread;
public:
    QAudioFormat audioFormat;

    HWIO() : QObject(QGuiApplication::instance()) {

        AudioIO *audioIO = new AudioIO;
        audioFormat.setSampleRate(SAMPLES_PER_SECOND);
        audioFormat.setChannelCount(NCHANNELS);
        audioFormat.setSampleSize(8*BYTES_PER_SAMPLE);
        audioFormat.setSampleType(QAudioFormat::SignedInt);
        audioFormat.setCodec("audio/pcm");
        audioFormat.setByteOrder(QAudioFormat::LittleEndian);

        outName = defaultDev(QAudio::AudioOutput);
        inName = defaultDev(QAudio::AudioInput);

        audioIO->moveToThread(&audioThread);
        connect(&audioThread, &QThread::finished, audioIO, &QObject::deleteLater);
        connect(this, &HWIO::startAudioThread, audioIO, &AudioIO::start);
        audioThread.start();
        connect(this, &HWIO::outNameChanged, this, &HWIO::resetAudio, Qt::QueuedConnection);
        connect(this, &HWIO::inNameChanged, this, &HWIO::resetAudio, Qt::QueuedConnection);
    }

    ~HWIO() {
        audioThread.quit();
        audioThread.wait();
    }

    QString defaultDev(QAudio::Mode mode) {
        QAudioDeviceInfo dev;
        if (mode == QAudio::AudioOutput)
            dev = QAudioDeviceInfo::defaultOutputDevice();
        else
            dev = QAudioDeviceInfo::defaultInputDevice();
        if (!dev.isNull()) return dev.deviceName();
        QStringList names = devNames(mode);
        if (names.length() != 0) return names[0];
        return "";
    }

    QStringList devNames(QAudio::Mode mode) {
        QList<QAudioDeviceInfo> devs = QAudioDeviceInfo::availableDevices(mode);
        QStringList names;
        qDebug() << "\n\n\n-------------------------------------------------------------------------------";
        for (QList<QAudioDeviceInfo>::iterator dev = devs.begin(); dev != devs.end(); ++dev)
            if (dev->isFormatSupported(audioFormat))
                names << dev->deviceName();
        qDebug() << "-------------------------------------------------------------------------------\n\n\n";
        return names;
    }

    Q_INVOKABLE QVariant outList() {
        return QVariant::fromValue(devNames(QAudio::AudioOutput));
    }

    Q_INVOKABLE QVariant inList() {
        return QVariant::fromValue(devNames(QAudio::AudioInput));
    }

    QString getOutName() {
        return outName;
    }

    void setOutName(QString name) {
        outName = name;
        emit outNameChanged(name);
    }

    QString getInName() {
        return inName;
    }

    void setInName(QString name) {
        inName = name;
        emit inNameChanged(name);
    }

    QAudioDeviceInfo devFromName(QString name, QAudio::Mode mode) {
        QList<QAudioDeviceInfo> devs = QAudioDeviceInfo::availableDevices(mode);
        QList<QAudioDeviceInfo>::iterator dev;
        for (dev = devs.begin(); dev != devs.end(); ++dev)
            if (dev->deviceName() == name && dev->isFormatSupported(audioFormat))
                return *dev;
        qWarning() << "device doesnt exist or support format:" << name;
        QString defName = defaultDev(mode);
        if (defName != name)
            return devFromName(defName, mode);
        qWarning() << "proceding without" << mode << "device";
        return QAudioDeviceInfo();
    }


    Q_INVOKABLE void resetAudio() {
        QAudioDeviceInfo outDev = devFromName(outName, QAudio::AudioOutput);
        QAudioDeviceInfo inDev = devFromName(inName, QAudio::AudioInput);

        emit startAudioThread(outDev, inDev, audioFormat);

    }

    Q_INVOKABLE static bool write(const QString fname, const QString content) {
        QDir("").mkpath(fname.section('/',0,-2));
        QFile f(fname);
        if (!f.open(WR))
            return false;
        QTextStream out(&f);
        out << content << endl;
        f.close();
        QFile::setPermissions(fname, PERM);
        return true;
    }

    Q_INVOKABLE static QString read(const QString fname) {
        QFile f(fname);
        if (!f.open(RD))
            return "";
        return QTextStream(&f).readAll();
    }

    Q_INVOKABLE static QString pwd() {
        return QDir::currentPath();
    }

    Q_INVOKABLE static QVariant listDir(const QString dname, const QString match) {
        QDirIterator modIt(dname,QStringList()<<match,QDir::Files|QDir::NoDot|QDir::NoDotDot|QDir::AllDirs,QDirIterator::FollowSymlinks);
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

signals:
    void outNameChanged(QString);
    void inNameChanged(QString);
    void startAudioThread(const QAudioDeviceInfo &outDev, const QAudioDeviceInfo &inDev, const QAudioFormat &format);
};

static HWIO *hwio;

void initHWIO(QQmlApplicationEngine *engine) {
    hwio = new HWIO();
    engine->globalObject().setProperty("HWIO", engine->newQObject(hwio));

    QDirIterator qrcIt(":/app", QStringList() << "*.qml", QDir::Files, QDirIterator::Subdirectories);
    while (qrcIt.hasNext()) {
        QString fname = qrcIt.next();
        QString typeName = fname.split('/').last().chopped(4);

        if (fname.startsWith(":/app/modules/") || fname.startsWith(":/app/patches/")) {
            QString dstpath = fname.section('/',2,-1);
            if (!(fname == ":/app/patches/autosave.qml" && HWIO::read(dstpath) != ""))
                HWIO::write(dstpath, HWIO::read(fname));
            if (fname.startsWith(":/modules")) {
                qmlRegisterType(QUrl::fromLocalFile(dstpath), "modules", 1, 0, typeName.toLatin1().data());
            }
        } else {
            qmlRegisterType("qrc" + fname, "ohm", 1, 0, typeName.toLatin1().data());
        }
    }

    QDirIterator modIt("modules", QStringList() << "*.qml",
                       QDir::Files, QDirIterator::Subdirectories);
    while (modIt.hasNext()) {
        QString fname = modIt.next();
        qmlRegisterType(QUrl::fromLocalFile(fname), "modules", 1, 0,
                        fname.split('/').last().chopped(4).toLatin1().data());
    }
}

#include "hwio.moc"
