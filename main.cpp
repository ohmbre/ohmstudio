#include <QProcessEnvironment>
#include <QtWebEngine/QtWebEngine>

#include "common.h"

int main(int argc, char *argv[]) {

    qputenv("QV4_MAX_CALL_DEPTH", "8192");
    qputenv("QV4_JS_MAX_STACK_SIZE", "16777216");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    QtWebEngine::initialize();
    engine.globalObject().setProperty("global", engine.globalObject());

    initBackend(&engine);
    initHWIO(&engine);

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));


    return app.exec();
}
