pragma Singleton
import QtQuick 2.10

QtObject {
    property QtObject jack: QtObject {
        property string dirIn: "in"
        property string dirOut: "out"
    }
}
