
#ifndef INCLUDE_FILEIO_HPP
#define INCLUDE_FILEIO_HPP
#include "common.hpp"


class FileIO : public QObject {
    Q_OBJECT

public:
    FileIO();
    Q_INVOKABLE static bool write(const QString fname, const QString content);
    Q_INVOKABLE static QString read(const QString fname);
    Q_INVOKABLE static QString pwd();
    Q_INVOKABLE static QVariant listDir(const QString dname, const QString match, const QString base);
    Q_INVOKABLE static QString objName(QObject *obj) { return qmlEngine(obj)->rootContext()->nameForObject(obj); }


};

#endif
