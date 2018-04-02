import QtQuick 2.10
import QtQuick.Controls 2.2


ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: "Ohm Studio"
    color: Style.patchBackgroundColor

    FontLoader { id: asapFont; source: "fonts/Asap-Medium.ttf" }


    Drawer {
        id: setup
        width: 0.33 * parent.width
        height: parent.height
        TextField {
            id: patchUrl
            text: "basic.qml"
            width: parent.width * 0.9
            height: 30
        }
        Button {
            y: 50
            text: "Load Patch"
            onClicked: {
                var component = Qt.createComponent("patch/example/"+patchUrl.text);
                if (component.status === Component.Error) {
                    console.log(component.errorString());
                    return;
                }
                console.log("loaded");
                var data = component.createObject(window,{});
                //var data = Qt.createQmlObject(F.readFile("patch/example/"+patchUrl.text), window, "");
                activePatch.setSource("patch/PatchView.qml", {patch: data});
                setup.close();
            }
        }

        Component.onCompleted: open()
    }

    Loader {
        id: activePatch
        anchors.fill: parent
        onLoaded: console.log("active patch loaded")
    }

}
