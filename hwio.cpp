#include <QObject>
#include <QIODevice>
#include <QAudioOutput>
#include <QAudioDeviceInfo>
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QDirIterator>
#include <QQmlContext>
#include <QGuiApplication>

void fillBuffer(short *buf, qint64 nframes);

#define SAMPLE_RATE 48000
#define BYTES_PER_SAMPLE 2
#define NCHANNELS 2
#define BYTES_PER_FRAME 4
#define BUFSIZE 8192LL

class HWIO : public QIODevice {
    Q_OBJECT
    Q_PROPERTY(QString outName READ getOutName WRITE setOutName NOTIFY outNameChanged)
public:
    QScopedPointer<QAudioOutput> audioOut;
    QString outName;

    HWIO(QObject *parent) : QIODevice (parent), outName(defaultDev().deviceName()) {
        qDebug() << "default out device is:" << outName;
        setOpenMode(QIODevice::ReadWrite);
        connect(this, &HWIO::outNameChanged, this, &HWIO::resetOut);
    }

    ~HWIO() {
        if (!audioOut.isNull()) audioOut->stop();
    }

    static QAudioFormat& audioFormat() {
        static QAudioFormat fmt;
        fmt.setSampleRate(SAMPLE_RATE);
        fmt.setChannelCount(NCHANNELS);
        fmt.setSampleSize(8*BYTES_PER_SAMPLE);
        fmt.setSampleType(QAudioFormat::SignedInt);
        fmt.setCodec("audio/pcm");
        fmt.setByteOrder(QAudioFormat::LittleEndian);
        return fmt;
    }

    static QAudioDeviceInfo defaultDev() {
        QAudioDeviceInfo dev = QAudioDeviceInfo::defaultOutputDevice();
        if (dev.deviceName() != "") return dev;
        QList<QAudioDeviceInfo> available = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
        for (QList<QAudioDeviceInfo>::iterator dev = available.begin(); dev != available.end(); ++dev)
            if (dev->isFormatSupported(audioFormat()))
                return *dev;
        qWarning() << "Could not find a compatible audio device";
        exit(1);
    }

    Q_INVOKABLE QVariant outList() {
        QList<QAudioDeviceInfo> devs = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
        QStringList outs;
        qDebug() << "\n\n\n-------------------------------------------------------------------------------";
        for (QList<QAudioDeviceInfo>::iterator dev = devs.begin(); dev != devs.end(); ++dev)
            if (dev->isFormatSupported(audioFormat()))
                outs << dev->deviceName();
        qDebug() << "-------------------------------------------------------------------------------\n\n\n";

        return QVariant::fromValue(outs);
    }

    QString getOutName() {
        return outName;
    }

    void setOutName(QString name) {
        outName = name;
        emit outNameChanged(name);
    }

    Q_INVOKABLE void resetOut() {
        QList<QAudioDeviceInfo> devs = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
        QList<QAudioDeviceInfo>::iterator dev;
        for (dev = devs.begin(); dev != devs.end(); ++dev)
            if (dev->deviceName() == outName)
                break;
        if (dev == devs.end()) {
            outName = defaultDev().deviceName();
            emit outNameChanged(outName);
            return;
        }

        if (!dev->isFormatSupported(audioFormat())) {
            qWarning() << "device does not support out audio format:" << outName;
            return;
        }

        if (!audioOut.isNull()) audioOut->stop();
        audioOut.reset(new QAudioOutput(*dev,audioFormat(),this));
        audioOut->setBufferSize(BUFSIZE);
        audioOut->start(this);

        qDebug() << "audio output started";
        if (audioOut->bufferSize() != BUFSIZE)
            qWarning() << "buffer size is" << audioOut->bufferSize();

    }


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

    qint64 readData(char *data, qint64 maxSize) {
        if (maxSize == 0) return 0;
        qint64 len = qMin(BUFSIZE, maxSize);
        fillBuffer(reinterpret_cast<short*>(data), len / BYTES_PER_FRAME);
        return len;
    }

    qint64 writeData(const char *, qint64 ) {
        return 0;
    }

signals:
    void outNameChanged(QString);
};

static HWIO *hwio;

void initHWIO(QGuiApplication *app, QQmlContext *root) {
    hwio = new HWIO(app);
    root->setContextProperty("HWIO", hwio);
}

#include "hwio.moc"
