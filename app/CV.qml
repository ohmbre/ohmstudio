import QtQuick 2.11

Model {
    id: cv
    objectName: "CV"
    property string label
    property string displayLabel: label
    property double controlVolts: 0
    onControlVoltsChanged: engine.setControl(uuid(cv),controlVolts)

    property var inVolts: null
    property var voltStream: (vc,vi) => vi ? `(${vc} + ${vi})` : vc
    property var unitStream: v => v
    property var stream: unitStream(voltStream(`control(${uuid(cv)})`, inVolts))
    property Component controller: CVController {}

    function evaluate(v) {
        let ret = math.parse(unitStream(v))
        ret = math.simplify(ret)
        ret = ret.toString({implicit: 'hide', parenthesis: 'auto'})
        ret = ret.replace(" * ",'')
        ret = math.parse(ret)
        ret = ret.toString({implicit: 'hide', parenthesis: 'auto'})
        const num = parseFloat(ret)
        const unit = ret.replace(/^[e0-9\.\- ]*/,'')
        if (unit)
            try {
                return math.unit(num+' '+unit).toString().split(' ')
            } catch(e) {
                console.log('num:',num,'unit:',unit,'error:',e);
            }

        return [num,'']
    }

    function toQML(indent) {
        return controlVolts.toString();
    }

    Component.onCompleted: {
        controlVoltsChanged.connect(userChanges);
    }

}
