import QtQuick 2.11

Model {
    id: cv
    objectName: "CV"
    property string label

    property double controlVolts: 0
    onControlVoltsChanged: engine.updateControl(Fn.uuid(cv),controlVolts)

    property var inVolts: 0
    property var stream: '(add((%1), control(%2)))'.arg(inVolts).arg(Fn.uuid(cv))
    property string knobReading: ''
    property Component control: Knob {}

    function toQML(indent) {
        return controlVolts.toString();
    }

    Component.onCompleted: {
        controlVoltsChanged.connect(userChanges);
    }

}
