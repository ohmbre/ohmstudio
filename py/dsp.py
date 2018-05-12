import math,time,threading
import random
from collections import Iterator

from PySide2.QtCore import QObject, Property, Slot, QThread
from PySide2.QtQml import qmlRegisterType,QJSValue,QJSEngine
from PySide2.QtScript import  QScriptEngine
from PySide2.QtMultimedia import QAudioOutput

import alsaaudio

SAMPLE_RATE = 48000
SAMPLE_BLOCK = 512
SAMPLE_BYTES = 4
SAMPLE_MIN = -1
SAMPLE_MAX = 1
VOLTS_MIN = -10
VOLTS_MAX = 10

pi = math.pi
hz = 2*pi/SAMPLE_RATE
v = (SAMPLE_MAX-SAMPLE_MIN)/(VOLTS_MAX-VOLTS_MIN)
s = SAMPLE_RATE
ms = s/1000.0  

ENGINE = QScriptEngine

class AudioThread(QThread):
   
    def __init__(self):
        QThread.__init__(self)

    @Slot()
    def run(self):
        self.pcm = alsaaudio.PCM(type = alsaaudio.PCM_PLAYBACK)
        self.pcm.setchannels(1)
        self.pcm.setrate(48000)
        self.pcm.setperiodsize(512)
        self.pcm.setformat(alsaaudio.PCM_FORMAT_FLOAT_LE)

        if ENGINE == QScriptEngine:
            self.jsEngine = QScriptEngine()
            print(self.jsEngine.availableExtensions())
        else:
            self.jsEngine = QJSEngine()
            self.jsEngine.installExtensions(QJSEngine.ConsoleExtension)
        self.jsEngine.moveToThread(self.thread())
        self.jsEngine.setParent(self)
        self.jsEngine.globalObject().setProperty('audio',self.jsEngine.newQObject(self))
        AudioThread.setglobals(self.jsEngine.globalObject().setProperty)
        #self.jsEngine.globalObject().setProperty('newStream',newStream)

        self.code = open('ohm/dsp/impl.js').read()
        ret = self.jsEngine.evaluate(self.code)
        if ret.isError():
            print(ret.toString())
       
    @Slot(QJSValue)
    def write(self,pcm):
        self.pcm.write(pcm.toVariant().data())

    def setglobals(setprop):
        setprop('v',v)
        setprop('ms',ms)
        setprop('s',s)
        setprop('hz',hz)
        setprop('pi',pi)
        setprop('SAMPLE_BLOCK', SAMPLE_BLOCK)
        setprop('SAMPLE_BYTES', SAMPLE_BYTES)
        
        
    def register(engine):
        qmlRegisterType(AudioThread,'ohm.dsp', 1, 0, 'AudioThread')
        AudioThread.setglobals(engine.rootContext().setContextProperty)
        
