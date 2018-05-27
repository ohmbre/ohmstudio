import ohm 1.0

CV {
    objectName: 'LinearCV'
    
    property string from
    stream:  '(('+from+') + ('+inVolts+') + ('+controlVolts+')*v)'
}
