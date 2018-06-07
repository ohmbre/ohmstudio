import ohm 1.0

CV {
    objectName: "LogScaleCV"
    
    property var logBase: 2
    property var from
    stream: '(%1 * (%2)^((%3)+control(%4)))'.arg(from).arg(logBase).arg(inVolts).arg(id);
}
