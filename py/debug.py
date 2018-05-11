import code,math,os,signal,sys,struct,time,threading

from PySide2.QtGui import QGuiApplication
from PySide2.QtCore import QObject,QUrl,QCoreApplication,QThread,Signal,Slot
from PySide2.QtQuick import QQuickView
from PySide2.QtQml import QQmlApplicationEngine


class DebugThread(QThread):
    def __init__(self, main):
        QThread.__init__(self)
        self.main = main
        
    def run(self):
        import readline
        import rlcompleter
               
        readline.parse_and_bind("tab: complete")
        ivars = dict(globals(), **locals())
        ivars['find'] = self.find
        ivars['dump'] = self.dump
        code.interact(local=ivars, banner="") 
        os.kill(os.getpid(),signal.SIGINT)

    def find(self, name):
        return self.main.window.findChildren(QObject, name)

    def dump(self, obj):
        for prop in sorted(dir(obj)):
            if prop.startswith("__"): continue
            print(prop + ': ' + str(obj.__getattribute__(prop)))
        if not 'metaObject' in dir(obj): return
        mobj = obj.metaObject()
        for p in range(mobj.propertyCount()):
            prop = mobj.property(p).name()
            def propval(name):
                try: return str(obj.property(name))
                except Exception as e: return str(e)
            print("property('"+prop+"'): "+propval(prop))
        for m in range(mobj.methodCount()):
            meth = mobj.method(m)
            pnames = ','.join(str(pname) for pname in meth.parameterNames())
            print(meth.name() + "(" + pnames + ")")

