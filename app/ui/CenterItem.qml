import QtQuick 2.11

Item {
    property Item centerIn
    property Item centerOn
    property Component contents
    x: centerIn.width/2
    y: centerIn.height/2
    Item {
        x: -loader.item.width/2
        y: -loader.item.height/2

        Loader {
            id: loader
            sourceComponent: contents
        }
    }
}
