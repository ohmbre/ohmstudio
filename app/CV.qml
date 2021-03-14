import ohm 1.0
import QtQuick

Model {
    id: cv
    property string label
    property string displayLabel: label
    property double volts: 0

    property Component controller: CVController {}
    property var translate: null
    property string unit: ''
    property bool hasTranslation: translate || unit
    property double voltsTrunc: Math.round(volts*100)/100
    property real transVal: translate ? translate(voltsTrunc) : voltsTrunc
    property int decimals: 2
    property string translation: transVal.toFixed(decimals) + (unit ? ' '+unit : '')

    function repr() {
        if (translate === null && units === null)
            return null;
        return (translate ? translate(volts) : volts) + (units ? (' '+units) : '')
    }

    exports: ({label: 'label', volts: 'volts'})


}
