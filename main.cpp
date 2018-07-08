#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QDirIterator>
#include <QQmlContext>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QJsonObject>
#include <QtNetwork/QTcpServer>
#include <QtNetwork/QTcpSocket>

#include <stdio.h>
#include <string.h>
#include <errno.h>


#ifdef __EMSCRIPTEN__
#include "engine/wasm.h"
class WasmEngine : public QObject {
  Q_OBJECT
public:
  Q_INVOKABLE void msg(QString json) {
    platform_enginemsg(json.toUtf8().data());
  }
};
#else
#include <QtWebView>
#include "engine/native.h"
#endif


class FileIO : public QObject {
  Q_OBJECT

public:

  static bool qwrite(QString fname, QString content) {
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

  static void transfer_from_storage() {
    QJsonDocument storage = platform_loadstorage();
    if (!storage.isEmpty() && storage.isObject()) {
      QJsonObject json = storage.object();
      for (QJsonObject::iterator it = json.begin(); it != json.end(); it++) {
    QString fname = it.key();
    QDir cwd("");
    cwd.mkpath(fname.section('/',0,-2));
    QString contents = it.value().toString();
    FileIO::qwrite(fname,contents);
      }
    }
  }

  Q_INVOKABLE static bool write(QString fname, QString content) {
    bool ret = qwrite(fname, content);
    platform_save(fname.toLatin1().data(), content.toUtf8().data());
    return ret;
  }

  Q_INVOKABLE static QString read(QString fname) {
    QFile f(fname);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
      return "";
    QTextStream in(&f);
    QString ret = in.readAll();
    return ret;
  }
  Q_INVOKABLE static QVariant listDir(QString dname, QString match) {
    transfer_from_storage();
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

  Q_INVOKABLE static bool canUpload() {
    return platform_canupload;
  }

  Q_INVOKABLE static void upload(QString dir) {
    platform_upload(dir.toLatin1().data());
  }

protected:
    ~FileIO() {}
};



class StupidHTTPServer : public QTcpServer {
    Q_OBJECT
public:
    StupidHTTPServer() {
        listen(QHostAddress::Any, 60600);
        QObject::connect(this,SIGNAL(newConnection()),
                         this,SLOT(handleConnection()));
    }
    ~StupidHTTPServer() {}
public slots:
    void handleRead() {
        QTcpSocket *socket = qobject_cast<QTcpSocket*>(QObject::sender());
        if (socket->canReadLine()) {
            QString fname = ":"+ QString(socket->readLine()).split(" ")[1];
            QFile f(fname);
            QTextStream out(socket);
            if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
                QString size = QString::number(f.size());
                QString ext = fname.split('.').last();
                QString header = "HTTP/1.0 200 Ok\r\n";
                header += "Content-Type: text/";
                header += ((ext == "js") ? "javascript" : ext) + ";\r\n";
                header += "Content-Length: "+size+";\r\n\r\n";
                out << header;
                QString body = f.readAll();
                out << body;
                f.close();
            }
        }
        socket->close();
        if (socket->state() == QTcpSocket::UnconnectedState)
            delete socket;
    }
    void handleConnection() {
        QTcpSocket *socket = nextPendingConnection();
        connect(socket, SIGNAL(readyRead()), this, SLOT(handleRead()));
    }
};

#include "main.moc"

int main(int argc, char *argv[]) {

  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;

#ifndef __EMSCRIPTEN__
  QtWebView::initialize();
#endif

  QDirIterator qrcIt(":", QStringList() << "*.qml",
             QDir::Files, QDirIterator::Subdirectories);
  while (qrcIt.hasNext()) {
    QString fname = qrcIt.next();
    if (fname.startsWith(":/modules/") || fname.startsWith(":/patches/")) {
      QDir cwd("");
      cwd.mkpath(fname.section('/',1,-2));
      QFile::copy(fname, fname.section('/',1,-1));
      QFile::setPermissions(fname.section('/',1,-1),
                QFileDevice::ReadOwner | QFileDevice::WriteOwner |
                QFileDevice::ReadGroup | QFileDevice::ReadOther);
    } else
      qmlRegisterType("qrc" + fname, "ohm", 1, 0,
              fname.section('/',-1).chopped(4).toLatin1().data());
  }

  FileIO::transfer_from_storage();

  QDirIterator modIt("modules", QStringList() << "*.qml",
             QDir::Files, QDirIterator::Subdirectories);
  while (modIt.hasNext()) {
    QString fname = modIt.next();
    qmlRegisterType(QUrl::fromLocalFile(fname), "modules", 1, 0,
            fname.split('/').last().chopped(4).toLatin1().data());
  }

  engine.rootContext()->setContextProperty("platform_name", platform_name);
#ifdef __EMSCRIPTEN__
    engine.rootContext()->setContextProperty("WasmEngine", new WasmEngine());
#else
  StupidHTTPServer lameness;
#endif
  engine.rootContext()->setContextProperty("FileIO", new FileIO());
  engine.load(QUrl(QStringLiteral("qrc:/OhmStudio.qml")));

  if (engine.rootObjects().isEmpty())
    return -1;

  return app.exec();
}
