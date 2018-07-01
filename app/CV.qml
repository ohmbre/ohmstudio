import QtQuick 2.11

Model {
    id: cv
    objectName: "CV"
    property string label

    property string _uuid
    function uuid() {
	if (_uuid) return _uuid
	_uuid = Fn.uniqId()
	return _uuid
    }

    	
    property double controlVolts: 0
    onControlVoltsChanged: engine.updateControl(uuid(), controlVolts);

    property var inVolts: 0
    property var stream: '(add((%1), control(%2)))'.arg(inVolts).arg(uuid())
    property string knobReading: ''

    function toQML(indent) {
        return controlVolts.toString();
    }

    Component.onCompleted: {
        controlVoltsChanged.connect(userChanges);
    }

}
