#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDirIterator>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QDirIterator modIt("modules", QStringList() << "*.qml",
		       QDir::Files, QDirIterator::Subdirectories);
    while (modIt.hasNext()) {
      QString fname = modIt.next();
      qmlRegisterType(QUrl::fromLocalFile(fname), "modules", 1, 0,
		      fname.split('/').last().chopped(4).toLatin1().data());
    }

    QDirIterator qrcIt(":", QStringList() << "*.qml",
		       QDir::Files, QDirIterator::Subdirectories);
    while (qrcIt.hasNext()) {
      QString fname = qrcIt.next();
      qmlRegisterType("qrc" + fname, "ohm", 1, 0,
		      fname.midRef(2).chopped(4).toLatin1().data());
    }


    engine.load(QUrl(QStringLiteral("qrc:/OhmStudio.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
