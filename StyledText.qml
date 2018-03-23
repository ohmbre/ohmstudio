import QtQuick 2.10

Text {
    property bool centered: true
    anchors.centerIn: centered ? parent : undefined
    fontSizeMode: Text.FixedSize
    textFormat: Text.AutoText
    horizontalAlignment: centered ? Text.AlignHCenter : undefined
    wrapMode: Text.WordWrap
    color: "#ffffff"
    font.family: asapFont.name
    font.pixelSize: 9
    font.weight: Font.Medium
}
