CV {
    id:lincv
    objectName: 'LinearCV'

    property var from
    knobReading: {
        var fromVal = parseFloat(from)
        var fromStr = fromVal.toString()
        if (fromStr === 'NaN') return ''
        var units = from.toString().replace(fromStr,'')
        units = units.replace('/mins',' bpm')
        var ret = fromVal + controlVolts
        return ret.toFixed(1).toString()+units
    }

    stream: '((%1)+(%2)+control(%3))'.arg(from).arg(inVolts).arg(Fn.uuid(lincv))
}
