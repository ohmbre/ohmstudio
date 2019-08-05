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
#include <QQmlApplicationEngine>
#include <QThread>
#include <QString>

void fillBuffer(short *buf, qint64 nframes);

constexpr auto SAMPLE_RATE = 48000;
constexpr auto BYTES_PER_SAMPLE = 2;
constexpr auto NCHANNELS = 2;
constexpr auto BYTES_PER_FRAME = 4;
constexpr auto BUFSIZE = 4096LL;
constexpr auto RD = QIODevice::ReadOnly|QIODevice::Text;
constexpr auto WR = QIODevice::ReadWrite|QIODevice::Truncate|QIODevice::Text;
constexpr auto PERM = QFileDevice::ReadOwner|QFileDevice::WriteOwner|QFileDevice::ReadGroup|QFileDevice::ReadOther;


class Output : public QIODevice {
    Q_OBJECT
    QScopedPointer<QAudioOutput> audioOut;

public slots:
    void start(const QAudioDeviceInfo &dev, const QAudioFormat &format) {
        setOpenMode(QIODevice::ReadWrite);
        if (!audioOut.isNull()) audioOut->stop();
        audioOut.reset(new QAudioOutput(dev,format,this));
        audioOut->setBufferSize(BUFSIZE);
        audioOut->start(this);
        qDebug() << "audio output started: bufsize =" << audioOut->bufferSize();
    }

public:

    ~Output() {
        if (!audioOut.isNull()) audioOut->stop();
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
};

class HWIO : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString outName READ getOutName WRITE setOutName NOTIFY outNameChanged)
    QString outName;
    QThread outThread;
public:

    HWIO(QObject *parent) : QObject(parent), outName(defaultDev().deviceName()) {
        qDebug() << "default out device is:" << outName;
        Output *output = new Output;

        output->moveToThread(&outThread);
        connect(&outThread, &QThread::finished, output, &QObject::deleteLater);
        connect(this, &HWIO::startOutThread, output, &Output::start);
        outThread.start();
        connect(this, &HWIO::outNameChanged, this, &HWIO::resetOut, Qt::QueuedConnection);
    }

    ~HWIO() {
        outThread.quit();
        outThread.wait();
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
        if (dev == devs.end() || !dev->isFormatSupported(audioFormat())) {
            qWarning() << "device doesnt exist or support format:" << outName;
            QString def = defaultDev().deviceName();
            if (outName == def) exit(1);
            outName = def;
            emit outNameChanged(outName);
            return;
        }

        emit startOutThread(*dev, audioFormat());

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
    void startOutThread(const QAudioDeviceInfo &info, const QAudioFormat &format);
};

static HWIO *hwio;

void initHWIO(QGuiApplication *app, QQmlContext *root) {
    hwio = new HWIO(app);
    root->setContextProperty("HWIO", hwio);

    QDirIterator qrcIt(":/app", QStringList() << "*.qml", QDir::Files, QDirIterator::Subdirectories);
    while (qrcIt.hasNext()) {
        QString fname = qrcIt.next();
        QString typeName = fname.split('/').last().chopped(4);

        if (fname.startsWith(":/app/modules/") || fname.startsWith(":/app/patches/")) {
            QString dstpath = fname.section('/',2,-1);
            if (fname != ":/app/patches/autosave.qml")
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
