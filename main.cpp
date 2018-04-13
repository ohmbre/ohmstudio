#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSurfaceFormat>

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;
  engine.addImportPath("qrc:/");
  engine.loadData("import ohm 1.0; Ohm{}");
  return app.exec();
}
