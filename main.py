#!/usr/bin/env python3
import asyncio,code,concurrent,math,os,signal,sys,struct,time,threading
from asyncio import *

from PySide2.QtGui import QGuiApplication
from PySide2.QtCore import QObject,QUrl,QCoreApplication,QThread,Signal,Slot
from PySide2.QtQuick import QQuickView
from PySide2.QtQml import QQmlApplicationEngine

FLOAT = struct.Struct("=f")
audio_out = aa.PCM(type=aa.PCM_PLAYBACK, mode=aa.PCM_NONBLOCK)
audio_out.setchannels(1)
audio_out.setrate(48000)
audio_out.setformat(aa.PCM_FORMAT_FLOAT_LE)

class Main(QObject):
    def __init__(self):
        self.synth_threads = []
        self.app = QGuiApplication(sys.argv)
        signal.signal(signal.SIGINT,signal.SIG_DFL)
    
        self.engine = QQmlApplicationEngine()
        self.engine.addImportPath(".")
        self.engine.loadData("import ohm 1.0; Ohm{}")
        self.window = self.engine.rootObjects()[0]
    
        patch_loader = self.window.findChild(QObject,"patchLoader")
        patch_loader.loaded.connect(self.patch_loaded)
        
    @Slot()
    def restart_synth(self):
        for thread in self.synth_threads:
            thread.stoptasks()
        for thread in self.synth_threads:
            thread.wait()
        self.synth_threads = [SynthesizeThread(self)]
        for thread in self.synth_threads:
            thread.start()

    @Slot()
    def patch_loaded(self):
        patch = self.window.findChild(QObject, "Patch")
        if not patch: return
        patch.modulesChanged.connect(self.restart_synth)
        self.restart_synth()
        print('patch loaded')

    def run(self):
        self.patch_loaded()
        self.app.exec_()

class SynthesizeThread(QThread):

    loop_header = """
async def runloop(self):
    while True:
        try:
            """
    loop_footer = """
        except concurrent.futures.CancelledError as e:
            print('stopping')
            break
    """
    setup_header = """
def runsetup(self):
    """

    def __init__(self,main):
        QThread.__init__(self)
        self.routines = []
        self.tasks = []
        self.main = main
        patch = self.main.window.findChild(QObject, "Patch")
        if not patch: return
        children = patch.findChildren(QObject)
        modules = [child for child in children if child.objectName().endswith("Module")]
        for module in modules:
            pySetup = module.property('pySetup')
            if pySetup:
                setup = self.setup_header + pySetup.replace('\n','\n' + ' '*4)
                exec(setup,globals())
                runsetup(module)
            pyLoops = module.property('pyLoops')
            for i in range(pyLoops.property('length').toInt()):
                loop = self.loop_header
                loop += pyLoops.property(i).toString().replace('\n','\n'+' '*12)
                loop += self.loop_footer
                exec(loop,globals())
                self.routines.append(runloop(module))
                
    def stoptasks(self):
        for task in self.tasks:
            task.cancel()
        
    def run(self):
        self.eventloop = new_event_loop()
        set_event_loop(self.eventloop)
        self.tasks = [ensure_future(routine) for routine in self.routines]
        self.eventloop.run_until_complete(gather(*self.tasks))
        print('thread exit')

class DebugThread(threading.Thread):
    def __init__(self, main):
        threading.Thread.__init__(self)
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


if __name__ == "__main__":
    main = Main()
    debug = DebugThread(main)
    debug.start()
    main.run()
    os.kill(os.getpid(), signal.SIGINT)

