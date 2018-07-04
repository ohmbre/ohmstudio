#include <emscripten.h>
#include <emscripten/html5.h>

extern "C" {
 
  void platform_enginemsg(const char *msg) {
    EM_ASM_({
	var jmsg = Pointer_stringify($0);
	window.ohmengine.handle(jmsg);
      }, msg);
  }
  
  void platform_save(const char *fname, const char *contents) {
    EM_ASM_({
	var jfname = Pointer_stringify($0);
	var jcontents = Pointer_stringify($1);
	window.localStorage.setItem(jfname, jcontents);
      }, fname, contents);
  }

  EM_JS(char *, emloadstorage, (), {
      var storage = window.localStorage;
      var nkeys = storage.length;
      var ret = {};
      for (var i = 0; i < nkeys; i++)
	ret[storage.key(i)] = storage.getItem(storage.key(i));
      var jstr = JSON.stringify(ret);
      var len = jstr.length*4+1;
      var buf = Module._malloc(len);
      stringToUTF8(jstr, buf, len);
      return buf;
    });
    
  void emfree(char *buf) {
    EM_ASM_({
	Module._free($0);
      }, buf);
  }
  
}

#include <QDebug>
#include <QString>
#include <QJsonDocument>
QJsonDocument platform_loadstorage() {
  char *data = emloadstorage();
  qDebug() << data;
  qDebug() << strlen(data);
  QJsonDocument doc = QJsonDocument::fromJson(data);
  emfree(data);
  return doc;
}



