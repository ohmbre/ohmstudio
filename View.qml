import QtQuick 2.10
import QtQuick.Shapes 1.0
import QtQuick.Controls 2.2

ApplicationWindow {
    id: window
    visible: true
    width: 320
    height: 240
    title: "Window Title"
    color: "black"

    FontLoader { id: asapFont; source: "Asap-Medium.ttf" }

    
    Drawer {
        id: setup
        width: 0.33 * parent.width
        height: parent.height
        TextField {
            id: patchUrl
            text: "basic.qml"
        }
        Button {
            y: 50
            text: "Load Patch"
            onClicked: {
                var component = Qt.createComponent(patchUrl.text);
                if (component.status === Component.Error) {
                    console.log(component.errorString());
                    return;
                }
                console.log("loaded");
                var data = component.createObject(window,{});
                activePatch.setSource("PatchView.qml", {patch: data});
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
