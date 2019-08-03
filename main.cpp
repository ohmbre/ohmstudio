#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QDirIterator>
#include <QDebug>

void initBackend(QGuiApplication *app, QQmlContext *root);
void initHWIO(QGuiApplication *app, QQmlContext *root);

int main(int argc, char *argv[]) {

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.globalObject().setProperty("global", engine.globalObject());

    QDirIterator qrcIt(":/app", QStringList() << "*.qml",
                       QDir::Files, QDirIterator::Subdirectories);
    while (qrcIt.hasNext()) {
        QString fname = qrcIt.next();
        if (fname.startsWith(":/app/modules/") || fname.startsWith(":/app/patches/")) {
            QDir cwd("");
            cwd.mkpath(fname.section('/',2,-2));
            QFile::copy(fname, fname.section('/',2,-1));
            QFile::setPermissions(fname.section('/',2,-1),
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
        qDebug() << fname << QUrl::fromLocalFile(fname) << fname.split('/').last().chopped(4).toLatin1().data();
        qmlRegisterType(QUrl::fromLocalFile(fname), "modules", 1, 0,
                        fname.split('/').last().chopped(4).toLatin1().data());
    }

    QQmlContext *root = engine.rootContext();
    initBackend(&app, root);
    initHWIO(&app, root);

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));

    return app.exec();
}
