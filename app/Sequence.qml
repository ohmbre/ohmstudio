import QtQuick 2.12

Model {
    id: seq
    property string label
    property var entries: [0]

    Component.onCompleted: {
        if (userChanges) entriesChanged.connect(userChanges);
    }

}
