#include <QProcessEnvironment>
#include <QtWebView/QtWebView>
#include <QQuickStyle>

#include "common.hpp"
#include "conductor.hpp"
#include "audio.hpp"
#include "fileio.hpp"
#include "symbolic.hpp"
#include "scope.hpp"

int main(int argc, char *argv[]) {

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSurfaceFormat format; format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    QJSValue g = engine.globalObject();
    AudioHWInfo audioHWInfo;
    FileIO fileIO;

    g.setProperty("global", g);
    g.setProperty("SymbolicFunction", engine.newQMetaObject(&SymbolicFunction::staticMetaObject));
    g.setProperty("AudioHWInfo", engine.newQObject(&audioHWInfo));
    g.setProperty("FileIO", engine.newQObject(&fileIO));
    qRegisterMetaType<SymbolicFunction*>("SymbolicFunction*");
    qRegisterMetaType<AudioOut*>("AudioOut");
    qRegisterMetaType<AudioIn*>("AudioIn");
    qmlRegisterType<Scope>("ohm", 1, 0, "AudioScope");


    maestro.moveToThread(&(maestro.thread));
    QMetaObject::invokeMethod(&maestro,"start", Qt::ConnectionType::QueuedConnection);
    maestro.thread.start();

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));

    return app.exec();
}
