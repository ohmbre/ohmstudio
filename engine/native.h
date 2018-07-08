#include <QJsonDocument>
#include <QString>

static QString platform_name = "native";
static bool platform_canupload = false;

extern "C" void platform_enginemsg(const char *) {}
extern "C" void platform_save(const char *, const char *) {}
QJsonDocument platform_loadstorage() { return QJsonDocument(); }
extern "C" void platform_upload(const char *) {}

