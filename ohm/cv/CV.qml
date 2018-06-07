import QtQuick 2.10

import ohm 1.0
import ohm.helpers 1.0

Model {
    objectName: "CV"
    readonly property string id: Fn.uniqId()

    property string label

    property double controlVolts: 0
    onControlVoltsChanged: updateControl(id, controlVolts);
    
    property var voltTicks: [-5,-4,-3,-2,-1, 0,1,2,3,4,5]
    property var inVolts: '0v'
    property var stream: '(add((%1), control(%2)))'.arg(inVolts).arg(id)

    function toQML(indent) {
	return controlVolts.toString();
    }

    Component.onCompleted: {
	controlVoltsChanged.connect(userChanges);
    }
    
}
