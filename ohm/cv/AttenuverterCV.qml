import ohm 1.0

CV {
    objectName: "AttenuverterCV"

    stream: controlVolts + ' * ' + inVolts
}
