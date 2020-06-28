#include "conductor.hpp"
#include "audio.hpp"
#include "fileio.hpp"
#include "scope.hpp"
#include "midi.hpp"
#include "dsp.hpp"

int main(int argc, char *argv[]) {

    qputenv("QSG_RENDER_LOOP", "threaded");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QSurfaceFormat format; format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    QJSValue g = engine.globalObject();
    FileIO fileIO;
    QQmlEngine::setContextForObject(&fileIO, engine.rootContext());
    g.setProperty("global", g);
    g.setProperty("SymbolicFunction", engine.newQMetaObject(&SymbolicFunction::staticMetaObject));
    g.setProperty("MIDIInFunction", engine.newQMetaObject(&MIDIInFunction::staticMetaObject));
    g.setProperty("AudioOut", engine.newQMetaObject(&AudioOut::staticMetaObject));
    g.setProperty("AudioIn", engine.newQMetaObject(&AudioIn::staticMetaObject));
    g.setProperty("Fourier", engine.newQMetaObject(&Fourier::staticMetaObject));
    g.setProperty("FileIO", engine.newQObject(&fileIO));
    g.setProperty("FRAMES_PER_SEC", FRAMES_PER_SEC);
    qmlRegisterInterface<Function>("Function");
    qRegisterMetaType<Function*>("Function*");
    qRegisterMetaType<SymbolicFunction*>("SymbolicFunction*");
    qRegisterMetaType<SymbolicFunction*>("BufferFunction*");
    qRegisterMetaType<MIDIInFunction*>("MIDIInFunction*");
    qRegisterMetaType<AudioOut*>("AudioOut*");
    qRegisterMetaType<AudioIn*>("AudioIn*");
    qRegisterMetaType<Fourier*>("Fourier*");
    qmlRegisterType<Scope>("ohm", 1, 0, "Scope");
    qmlRegisterType<FFTScope>("ohm", 1, 0, "FFTScope");

    maestro.start();

    engine.load(QUrl(QStringLiteral("qrc:/app/OhmStudio.qml")));
    int ret = app.exec();
    maestro.stop();
    return ret;
}
