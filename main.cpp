#include <QObject>
#include <QGuiApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>

void initBackend(QGuiApplication *app, QQmlApplicationEngine *engine);
void initHWIO(QGuiApplication *app, QQmlApplicationEngine *engine);

int main(int argc, char *argv[]) {

    qputenv("QV4_MAX_CALL_DEPTH", "8192");
    qputenv("QV4_JS_MAX_STACK_SIZE", "16777216");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.globalObject().setProperty("global", engine.globalObject());

    initHWIO(&app, &engine);
    initBackend(&app, &engine);

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));


    return app.exec();
}
