import ohm 1.0
import ohm.dsp 1.0

CV {
    objectName: "LogScaleCV"

    property double nth: 2
    property string from
    cv: with(DSP) mul(from,pow2(add(voltage,control)))

}
