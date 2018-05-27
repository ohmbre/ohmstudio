import ohm 1.0

CV {
    objectName: "LogScaleCV"
    
    property double logBase: 2
    property string from
    stream: from+' * ('+logBase+')^(('+inVolts+')+#'+controlVolts+')';
}
