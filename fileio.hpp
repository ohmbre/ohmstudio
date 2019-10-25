
#ifndef INCLUDE_FILEIO_HPP
#define INCLUDE_FILEIO_HPP

class FileIO : public QObject {
    Q_OBJECT

public:
    Q_INVOKABLE FileIO();
    Q_INVOKABLE bool write(const QString &fname, const QString &content);
    Q_INVOKABLE QString read(const QString &fname);
    Q_INVOKABLE QString pwd();
    Q_INVOKABLE QVariant listDir(const QString &dname, const QString &match, const QString &base);
    Q_INVOKABLE QJSValue samplesFromFile(QUrl url);

};



#endif
