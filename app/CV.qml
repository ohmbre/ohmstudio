import QtQuick 2.11

Model {
    id: cv
    objectName: "CV"
    property string label

    property double controlVolts: 0
    onControlVoltsChanged: engine.setControl(uuid(cv),controlVolts)

    property var inVolts: 0
    property var stream: '(add((%1), control(%2)))'.arg(inVolts).arg(uuid(cv))
    property string reading: ''
    property Component controller: KnobController {}

    function toQML(indent) {
        return controlVolts.toString();
    }

    Component.onCompleted: {
        controlVoltsChanged.connect(userChanges);
    }

}
