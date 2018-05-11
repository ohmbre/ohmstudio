import os,signal

from py.main import Main
from py.debug import DebugThread

if __name__ == "__main__":
    
    main = Main()
    debug = DebugThread(main)
    debug.start()
    main.run()
    os.kill(os.getpid(), signal.SIGINT)

