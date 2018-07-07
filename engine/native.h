#include <QJsonDocument>


QString platform_name = "native";
extern "C" {
  void platform_enginemsg(const char *) {
    //    printf("enginemsg: %s\n", msg);
  }
  void platform_save(const char *, const char *) {}
  QJsonDocument platform_loadstorage() { return QJsonDocument(); }
  bool platform_canupload = false;
  void platform_upload(const char *) {}
}
