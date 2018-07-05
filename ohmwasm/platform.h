#include <emscripten.h>
#include <emscripten/html5.h>


EM_JS(void, platform_enginemsg, (const char* msg), {
    var jmsg = UTF8ToString(msg);
    window.ohmengine.handle(jmsg);
  });
  
EM_JS(void, platform_save, (const char* fname, const char* contents), {
    var jfname = UTF8ToString(fname);
    var jcontents = UTF8ToString(contents);
    window.localStorage.setItem(jfname, jcontents);
    var link = document.createElement('a');
    link.setAttribute('href','data:text/plain;charset=utf-8,'+encodeURIComponent(jcontents));
    link.setAttribute('download', jfname);
    link.style.display = 'none';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  });


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

EM_JS(void, emfree, (const char* cbuf), {
    Module._free(cbuf);
  });


bool platform_canupload = true;
EM_JS(void, platform_upload, (char* directory), {
    var dir = UTF8ToString(directory);
    var fileElement = document.createElement("input");
    document.body.appendChild(fileElement);
    fileElement.type = "file";
    fileElement.style = "display:none";
    fileElement.accept = ".qml";
    fileElement.onchange = function(event) {
      const files = event.target.files;
      for (var i = 0; i < files.length; i++) {
	var reader = new FileReader();
	var file = files[i];
	reader.onload = function() {
	  window.localStorage.setItem(dir+'/'+file.name, reader.result);
	};
	reader.readAsText(file);
      }
    };
    fileElement.click();
  });



#include <QString>
#include <QJsonDocument>
QJsonDocument platform_loadstorage() {
  char *data = emloadstorage();
  QJsonDocument doc = QJsonDocument::fromJson(data);
  emfree(data);
  return doc;
}



