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
    QString ret = f.open(QIODevice::ReadOnly|QIODevice::Text) ? QTextStream(&f).readAll() : "";
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


Q_INVOKABLE QJSValue FileIO::samplesFromFile(QUrl path) {
    QList<V> samples;

    decodeSamples(QDir::toNativeSeparators(path.toLocalFile()), &samples);

    QJSValue ret = qmlEngine(this)->newArray(samples.size());
    for (int i = 0; i < samples.size(); i++)
        ret.setProperty(i, samples[i]*10);
    return ret;



}

