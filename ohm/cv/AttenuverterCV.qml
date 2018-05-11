import ohm 1.0

CV {
    objectName: "AttenuverterCV"

    cv: mul(voltage,control)
}
