import QtQuick 2.11
import QtQuick.Controls 2.4

ApplicationWindow {
    id: window
    visible: true
    flags: Qt.Window
    width: 640
    height: 480
    minimumWidth: 320
    minimumHeight: 240
    
    title: "Ohm Studio"
    color: Style.patchBackgroundColor

    Drawer {
        id: setup
	property real extension: 0
        width: 0.3*(1 + extension) * overlay.width * overlay.scale
        height: overlay.height * overlay.scale
	dragMargin: 15*overlay.scale
	
	Behavior on width { SmoothedAnimation { velocity: 300 } }
	
        background: Rectangle {
            height: setup.height + border.width * 2
	    width: setup.width + border.width * 2
	    x: -border.width
	    y: -border.width
	    
	    color: Style.drawerColor
	    border.width: 4*overlay.scale
	    border.color: Style.buttonBorderColor
        }
	
        Rectangle {
	    id: header
	    width: parent.width + 1;
	    height: 18 * overlay.scale
	    color: Style.buttonBorderColor
	    Image {
		source: "ui/icons/logo.svg"
		x: Fn.centerInX(this,parent)
		y: Fn.centerInY(this,parent)
		mipmap: true
                height: parent.height*.8
		width: parent.height*.8
	    }
        }
	
        OhmButton {
	    scale: overlay.scale
            y: 50*overlay.scale; x: parent.width - width + radius - 8*overlay.scale
	    text: "New Patch"
	    onClicked: {
		overlay.loadPatch('import ohm 1.0; Patch { modules: []; cables: [] }')
                setup.close();
	    }
        }
	
        OhmButton {
	    scale: overlay.scale
	    y: 100*overlay.scale; x: parent.width - width + radius - 8*overlay.scale
	    text: "Load Patch"
	    onClicked: {
                setup.open()
		setup.extension = 1
                saveFileChoose.close();
                loadFileChoose.open();
	    }
        }
	
        OhmButton {
	    scale: overlay.scale
	    y: 150*overlay.scale; x: parent.width - width + radius - 8*overlay.scale
	    visible: activePatch.status === Loader.Ready
	    text: "Save Patch"
	    onClicked: {
                if (!saveFileChoose.visible) {
		    setup.extension = 1
		    setup.open()
		    loadFileChoose.close();
		    saveFileChoose.open();
		    label.color = Style.fileChooseLitColor
                } else {
		    saveFileChoose.fileChosen(saveFileChoose.saveFile)
		    label.color = Style.buttonTextColor
                }
	    }
        }
	
        onClosed: function() {
	    loadFileChoose.close()
	    saveFileChoose.close()
	    setup.extension = 0
        }
	
        OhmFileChoose {
	    id: loadFileChoose
	    scale: overlay.scale
	    forLoading: true
	    directory: 'patches'
	    extension: 'qml'
	    onFileChosen: function(fileURL) {
                if (overlay.loadPatchQML(fileURL)) {
		    loadFileChoose.close()
		    setup.close();
		    setup.extension = 0
                }
	    }
        }
	
        OhmFileChoose {
	    id: saveFileChoose
	    scale: overlay.scale
	    forSaving: true
	    directory: 'patches'
	    extension: 'qml'
	    onFileChosen: function(fileURL) {
                activePatch.item.patch.saveTo(fileURL);
                saveFileChoose.close()
                setup.close()
		setup.extension = 0
	    }
        }
    }
    


    Item {
	id: overlay
	width: 320
	height: width * window.height / window.width
	scale: window.width / width
	transformOrigin: Item.TopLeft
	FontLoader { id: asapFont; source: "ui/fonts/Asap-Medium.ttf" }

	QtObject {
	    id: engine
	    
	    function set(key, val) {
		var msg = { cmd: 'set', key: key, val: val }
		ohmengine.msg(JSON.stringify(msg))
	    }
	    
	    function setsubkey(key,subkey,val) {
		var msg = { cmd: 'set', key: key, subkey: subkey, val: val }
		ohmengine.msg(JSON.stringify(msg))
	    }

	    function updateControl(uuid,val) {
		setsubkey('control',uuid,val)
	    }
	}
	
	function loadPatchQML(url) {
            var rawdata = Fn.readFile(url);
	    if (!rawdata) return false
	    return loadPatch(rawdata)
	}
	
	function loadPatch(raw,url) {
	    if (!url) url="dynamic"
	    if (activePatch.item) {
		console.log('destroying active patch');
		activePatch.item.patch.destroy()
	    }
            try {
		var obj = Qt.createQmlObject(raw, window, url);
            } catch(err) {
		console.error("could not load ",url,":",err);
		return false;
            }
            activePatch.setSource("PatchView.qml", {patch: obj});
            return true;
	}
	
	Loader {
            id: activePatch
            objectName: "patchLoader"
            anchors.fill: parent
	}

	Component.onCompleted: {
            loadPatchQML(Constants.autoSavePath)
	    setup.open()
	}
    }
}

