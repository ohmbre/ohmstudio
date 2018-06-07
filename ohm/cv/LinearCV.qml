import ohm 1.0

CV {
    objectName: 'LinearCV'
    
    property var from
    stream: '((%1)+(%2)+control(%3))'.arg(from).arg(inVolts).arg(id)
}
