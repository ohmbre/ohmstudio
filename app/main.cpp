#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QDirIterator>
#include <QQmlContext>
#include <QFile>
#include <QTextStream>
#include <QDebug>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <emscripten/html5.h>
extern "C" {
  void msg_engine(const char *msg) {
    EM_ASM_({
	     var jstr = Pointer_stringify($0);
	     window.ohmengine.handle(jstr);
      }, msg);
  }
}   
class OhmEngine : public QObject {
  Q_OBJECT
public:
  Q_INVOKABLE void msg(QString json) {
    msg_engine(json.toUtf8().data());
  }
};
#endif /* EMSCRIPTEN */

class FileIO : public QObject {
  Q_OBJECT
public:
  Q_INVOKABLE bool write(QString fname, QString content) {
    QFile f(fname);
    if (!f.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text))
      return false;
    QTextStream out(&f);
    out << content << endl;
    return true;
  }
  Q_INVOKABLE QString read(QString fname) {
    QFile f(fname);
    if (!f.open(QIODevice::ReadOnly)) return "";
    QTextStream in(&f);
    return in.readAll();
  }
  Q_INVOKABLE QStringList listDir(QString dname, QString match) {
    QDirIterator modIt(dname, QStringList() << match,
		       QDir::Files | QDir::AllDirs | QDir::NoDot | QDir::NoDotDot,
		       QDirIterator::FollowSymlinks);
    QStringList fnames;  
    if (dname.contains('/')) fnames << dname + "/..";
    while (modIt.hasNext()) {
      QString fname = modIt.next();
      fnames << fname;
    }
    return fnames;
  }	
}; 


#include "main.moc"

int main(int argc, char *argv[]) {

  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;
  
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

  QDirIterator modIt("modules", QStringList() << "*.qml",
		     QDir::Files, QDirIterator::Subdirectories);
  while (modIt.hasNext()) {
    QString fname = modIt.next();
    qmlRegisterType(QUrl::fromLocalFile(fname), "modules", 1, 0,
		    fname.split('/').last().chopped(4).toLatin1().data());
  }

#ifdef __EMSCRIPTEN__
  engine.rootContext()->setContextProperty("ohmengine", new OhmEngine());  
#endif

  engine.rootContext()->setContextProperty("FileIO", new FileIO());
  engine.load(QUrl(QStringLiteral("qrc:/OhmStudio.qml")));

  if (engine.rootObjects().isEmpty())
    return -1;
  
  return app.exec();
}
