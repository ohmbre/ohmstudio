#!/usr/bin/env python3
import code,signal,sys

from PySide2.QtGui import QGuiApplication
from PySide2.QtCore import QObject,QUrl,QCoreApplication,Signal,Slot
from PySide2.QtQuick import QQuickView
from PySide2.QtQml import QQmlApplicationEngine

from . import alsa
from . import dsp

class Main(QObject):
    def __init__(self):
        self.app = QGuiApplication(sys.argv)
        signal.signal(signal.SIGINT,signal.SIG_DFL)
        self.engine = QQmlApplicationEngine()
        alsa.Alsa.register(self.engine)
        dsp.AudioThread.register(self.engine)
        self.engine.rootContext().setContextProperty('alsa',alsa.Alsa())
        self.engine.addImportPath(".")
        self.engine.loadData("import ohm 1.0; Ohm{}")
        self.window = self.engine.rootObjects()[0]

        patch_loader = self.window.findChild(QObject,"patchLoader")
        patch_loader.loaded.connect(self.patch_loaded)

    @Slot()
    def patch_loaded(self):
        patch = self.window.findChild(QObject, "Patch")
        if not patch: return
        self.patch = patch
        print('patch loaded')
    

    def run(self):
        self.app.exec_()
