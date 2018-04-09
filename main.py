#!/usr/bin/env python3
import os,signal,sys

os.environ.update({'QML_DISABLE_DISK_CACHE': '1',
                   'QT_QPA_PLATFORM': 'xcb',
                   'QT_SCALE_FACTOR': '2'}) 

from PySide2.QtGui import QGuiApplication
from PySide2.QtCore import QUrl,QCoreApplication
from PySide2.QtQuick import QQuickView
from PySide2.QtQml import QQmlApplicationEngine

app = QGuiApplication(sys.argv)
signal.signal(signal.SIGINT,signal.SIG_DFL)
engine = QQmlApplicationEngine()
engine.addImportPath(".")
engine.load(QUrl("main.qml"))
sys.exit(app.exec_())


