import QtQuick 2.12

Item {
    id: slider
    property real value
    property real from: -10
    property real to: 10
    property Component background
    property Component handle
    property alias handleItem: handleLoader.item
    property bool pressed: false
    property real position: (value - from)/(to - from)
    Loader {
        anchors.fill: parent
        sourceComponent: background
    }
    Item {
        anchors.fill: parent
        Loader {
            id: handleLoader
            sourceComponent: handle
        }

    }
    MouseArea {

        property var dragbegin: null
        anchors.fill: parent
        onPressed: {
            let p = mapToItem(handleItem, mouse.x, mouse.y)
            if (!handleItem.contains(p)) {
                value = mouse.x / slider.width * (to-from) + from
                p = mapToItem(handleItem, mouse.x, mouse.y)
            }
            dragbegin = p.x;
        }
        onPositionChanged: {
            if (dragbegin === null) return
            let p = mapToItem(handleItem, mouse.x, mouse.y)
            const dy = 1-global.clip(0,Math.abs(mouse.y-height/2)/50,0.99)
            const dx = p.x - dragbegin
            slider.value = global.clip(slider.from, slider.value+.21*dx*dy, slider.to)
            p = mapToItem(handleItem, mouse.x, mouse.y)
            dragbegin = p.x
        }
        onReleased: {
            dragbegin = null;
            slider.value = Math.round(100*slider.value) / 100
        }

        propagateComposedEvents: true
    }


}

