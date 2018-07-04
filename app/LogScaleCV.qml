CV {
    id: logcv
    objectName: "LogScaleCV"

    property var logBase: 2
    property var from
    knobReading: {
        var fromVal = parseFloat(from)
        var fromStr = fromVal.toString()
        if (fromStr === 'NaN') return ''
        var units = from.toString().replace(fromStr,'')
        units = units.replace('/mins',' bpm')
        var ret = fromVal * Math.pow(parseFloat(logBase),(controlVolts))
        return ret.toFixed(1).toString()+units
    }
    stream: '(%1 * (%2)^((%3)+control(%4)))'.arg(from).arg(logBase).arg(inVolts).arg(Fn.uuid(logcv));
}
