import os

HEAD,FOOT = '<RCC>\n    <qresource prefix="/">\n','    </qresource>\n</RCC>\n'

def generate_qrc():
    print("generating qml.qrc...")
    with open('qml.qrc','w') as qrc:
        qrc.write(HEAD)
        for path, dirs, files in os.walk(os.path.abspath(os.path.dirname(__file__))):
            for file in files:
                if file.endswith(".qml") or file.endswith(".ttf") or file.endswith(".js") or file == "qmldir": 
                    qrc.write('        <file alias="')
                    qrc.write(file)
                    qrc.write('">')
                    qrc.write(os.path.relpath(os.path.join(path,file)))
                    qrc.write("</file>\n")
        qrc.write(FOOT)

def generate_py():
    print("generating qmlqrc.py...")
    import subprocess
    qmlqrc = subprocess.check_output("pyside2-rcc qml.qrc", shell=True)
    with open('qmlqrc.py','w') as out:
        out.write(qmlqrc.decode())

def register_cached():
    try: import qmlqrc
    except:
        try: generate_py()
        except:
            print("...but first...")
            generate_qrc()
            print("...and now...")
            generate_py()
            import qmlqrc

def register():
    generate_qrc()
    generate_py()
    import qmlqrc

if __name__ == "__main__":
    import sys
    if "--qrc" in sys.argv:
        generate_qrc()
    if "--py" in sys.argv:
        generate_py()

