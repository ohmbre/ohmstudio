#!/usr/bin/env python3
import code,os,signal,sys,time,threading

from PySide2.QtGui import QGuiApplication
from PySide2.QtCore import QObject,QUrl,QCoreApplication
from PySide2.QtQuick import QQuickView
from PySide2.QtQml import QQmlApplicationEngine

class CodeThread(threading.Thread):
    def run(self):
        import readline
        import rlcompleter
        
        def find(name):
            return window.findChildren(QObject, name)
        
        readline.parse_and_bind("tab: complete")
        code.interact(local=dict(globals(), **locals())) 
        os.kill(os.getpid(),signal.SIGINT)



app = QGuiApplication(sys.argv)
signal.signal(signal.SIGINT,signal.SIG_DFL)
engine = QQmlApplicationEngine()
engine.addImportPath(".")
engine.loadData("import ohm 1.0; Ohm{}")
window = engine.rootObjects()[0]
thread = CodeThread()
thread.start()
app.exec_()
os.kill(os.getpid(), signal.SIGINT)



