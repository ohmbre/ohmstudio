pragma Singleton
import QtQuick 2.10

QtObject {
    property QtObject jack: QtObject {
        property int dirIn: 0
        property int dirOut: 1
    }
}
