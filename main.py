import os,sys

os.environ["QML_DISABLE_DISK_CACHE"] = "1"

from PySide2.QtGui import QGuiApplication
from PySide2.QtCore import QUrl,QCoreApplication
from PySide2.QtQuick import QQuickView
from PySide2.QtQml import QQmlApplicationEngine

import qrc
qrc.register()
app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine(QUrl("qrc:/View.qml"))
res = app.exec_()
del res
sys.exit()
