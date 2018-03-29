#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSurfaceFormat>

int main(int argc, char *argv[]) {
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  //QSurfaceFormat f = QSurfaceFormat::defaultFormat();
  //f.setSamples(4);
  //QSurfaceFormat::setDefaultFormat(f);

  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine("qrc:/View.qml");
  return app.exec();
}
