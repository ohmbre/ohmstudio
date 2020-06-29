#include "fileio.hpp"
#include "conductor.hpp"


Q_INVOKABLE FileIO::FileIO() : QObject(QGuiApplication::instance()) {}

Q_INVOKABLE bool FileIO::write(const QString &relPath, const QString &content) {
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

Q_INVOKABLE  QString FileIO::read(const QString &relpath) {
    QString path = relpath.startsWith(":/") || relpath.startsWith("/") ? relpath
      : QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/" + relpath;
    QFile f(path);
    qDebug() << "read: " << path;
    QString ret = f.open(QIODevice::ReadOnly|QIODevice::Text) ? QTextStream(&f).readAll() : "";
    qDebug() << " res: " << ret;
    return ret;
}

Q_INVOKABLE  QString FileIO::pwd() {
    return QDir::currentPath();
}

Q_INVOKABLE  QVariant FileIO::listDir(const QString &dname, const QString &match, const QString &base) {    
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


Q_INVOKABLE QJSValue FileIO::samplesFromFile(QUrl url) {
    QAudioDecoder decoder;
    QList<double> samples;
    QAudioFormat fmt;
    QTimer timer;
    QEventLoop loop;

    decoder.setSourceFilename(QFileInfo(url.path()).absoluteFilePath());
    fmt.setChannelCount(1);
    fmt.setSampleSize(32);
    fmt.setSampleRate(FRAMES_PER_SEC);
    fmt.setCodec("audio/pcm");
    fmt.setSampleType(QAudioFormat::Float);
    fmt.setByteOrder(QAudioFormat::LittleEndian);
    decoder.setAudioFormat(fmt);
    timer.setSingleShot(true);
    connect(&decoder, &QAudioDecoder::finished, &loop, &QEventLoop::quit);
    connect(&decoder, &QAudioDecoder::bufferReady, &loop, &QEventLoop::quit);
    connect(&decoder, &QAudioDecoder::stateChanged, &loop, &QEventLoop::quit);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    decoder.start();

    bool started = decoder.state() == QAudioDecoder::DecodingState;
    while (decoder.error() == QAudioDecoder::NoError) {
        while (decoder.bufferAvailable()) {
            QAudioBuffer buf = decoder.read();
            float *data = (float*)buf.constData();
            for (int i = 0; i < buf.frameCount(); i++)
                samples.append(data[i]);
        }
        started = started || decoder.state() == QAudioDecoder::DecodingState;
        if (started && decoder.state() == QAudioDecoder::StoppedState)
            break;
        timer.start(2000);
        loop.exec();
    }


    QJSValue ret = qmlEngine(this)->newArray(samples.size());
    for (int i = 0; i < samples.size(); i++)
        ret.setProperty(i, samples[i]*10);
    return ret;

}

