import ohm 1.0

CV {
    objectName: "LogScaleCV"

    property double nth: 2
    property string from
    cv: mul(from,pow2(add(voltage,control)))

}
