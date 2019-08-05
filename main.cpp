#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>

void initBackend(QGuiApplication *app, QQmlContext *root);
void initHWIO(QGuiApplication *app, QQmlContext *root);

int main(int argc, char *argv[]) {

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.globalObject().setProperty("global", engine.globalObject());

    QQmlContext *root = engine.rootContext();
    initBackend(&app, root);
    initHWIO(&app, root);

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));

    return app.exec();
}
