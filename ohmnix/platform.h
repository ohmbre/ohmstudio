#include <QJsonDocument>

extern "C" {
  void platform_enginemsg(const char *msg) {
    printf("enginemsg: %s\n", msg);
  }
  void platform_save(const char *, const char *) {}
  QJsonDocument platform_loadstorage() { return QJsonDocument(); }
}
