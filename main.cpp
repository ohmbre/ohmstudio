#include "conductor.hpp"
#include "audio.hpp"
#include "fileio.hpp"
#include "scope.hpp"
#include "midi.hpp"

int main(int argc, char *argv[]) {

    qputenv("QSG_RENDER_LOOP", "threaded");
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
    g.setProperty("MIDIInFunction", engine.newQMetaObject(&MIDIInFunction::staticMetaObject));
    g.setProperty("AudioHWInfo", engine.newQObject(&audioHWInfo));
    g.setProperty("FileIO", engine.newQObject(&fileIO));
    qRegisterMetaType<SymbolicFunction*>("SymbolicFunction*");
    qRegisterMetaType<Function*>("Function*");
    qRegisterMetaType<AudioOut*>("AudioOut");
    qRegisterMetaType<AudioIn*>("AudioIn");
    qRegisterMetaType<MIDIInFunction*>("MIDIInFunction*");
    qmlRegisterType<Scope>("ohm", 1, 0, "Scope");
    qmlRegisterType<FFTScope>("ohm", 1, 0, "FFTScope");

    maestro.setEngine(&engine);
    maestro.moveToThread(&(maestro.thread));
    QMetaObject::invokeMethod(&maestro,"start", Qt::ConnectionType::QueuedConnection);
    maestro.thread.start();

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));
    int ret = app.exec();
    maestro.thread.quit();
    return ret;
}
