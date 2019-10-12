#include "fileio.hpp"

constexpr auto RD = QIODevice::ReadOnly|QIODevice::Text;
constexpr auto WR = QIODevice::ReadWrite|QIODevice::Truncate|QIODevice::Text;
constexpr auto PERM = QFileDevice::ReadOwner|QFileDevice::WriteOwner|QFileDevice::ReadGroup|QFileDevice::ReadOther;

FileIO::FileIO() : QObject(QGuiApplication::instance()) {}

Q_INVOKABLE bool FileIO::write(const QString fname, const QString content) {
    QString path = fname.section('/',0,-2);
    if (path != "")
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

Q_INVOKABLE  QString FileIO::read(const QString fname) {
        QFile f(fname);
        if (!f.open(RD))
            return "";
        return QTextStream(&f).readAll();
}

Q_INVOKABLE  QString FileIO::pwd() {
    return QDir::currentPath();
}

Q_INVOKABLE  QVariant FileIO::listDir(const QString dname, const QString match, const QString base) {
    QDirIterator modIt(dname,QStringList()<<match,QDir::Files|QDir::NoDot|QDir::NoDotDot|QDir::AllDirs,QDirIterator::FollowSymlinks);
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



