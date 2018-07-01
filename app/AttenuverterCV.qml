import ohm 1.0

CV {
    objectName: 'AttenuverterCV'

    stream: '(%1) * control(%2)'.arg(inVolts).arg(id)
}
