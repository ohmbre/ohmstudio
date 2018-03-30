pragma Singleton
import QtQuick 2.10

QtObject {
    property color patchBackgroundColor: "black"

    property color moduleColor: "#FF426998" //"4b77a7"
    property color moduleSelectedColor: "#FF62ABFA"
    property color moduleBorderColor: "#FFCDCDCD"
    property int moduleBorderWidth: 2
    property real moduleLabelPadding: 6.5
    property real jackExtension: 10
    property color inJackColor: "#A0728872"
    property color inJackLitColor: "#FFD1D7DB"
    property color outJackColor: "#A0887272"
    property color outJackLitColor: "#FFD1D7DB"
    property real minJackGap: 0.1 // (radians)
    property real maxJackSweep: 1 // (radians)

    property color jackLabelColor: "#FFC8C8C8"
    property real jackLabelGap: 2

    property color edgeColor: "#FFCC5D4E"
    property double edgeControlStiffness: 5
}
