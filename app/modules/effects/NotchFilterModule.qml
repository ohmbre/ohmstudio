import ohm 1.0

Module {
    objectName: 'NotchFilterModule'

    label: 'Notch Filter'

    property var cs: `cos(@f)`
    property var sn: `sin(@f)`
    property var alpha: `${sn} * sinh(log(2)/2 * 1/@q * @f/${sn})`
    property var a0: `1 + ${alpha}`
    property var a1: `-2 * ${cs}`
    property var a2: `1 - ${alpha}`
    property var b0: `1`
    property var b1: `-2 * ${cs}`
    property var b2: `1`

    outJacks: [
        OutJack {
            label: '-12dB/oct'
            stream: `biquad($in,${a0},${a1},${a2},${b0},${b1},${b2})`
        },
        OutJack {
            label: '-24dB/oct'
            stream: `biquad(${outStream('-12dB/oct')},${a0},${a1},${a2},${b0},${b1},${b2})`
        }
    ]

    inJacks: [
        InJack {label: 'in'},
        InJack {label: 'f'},
        InJack {label: 'q'}
    ]

    cvs: [
        LogScaleCV {
            label: 'f'
            from: '200hz'
            logBase: 1.6
            inVolts: inStream('f')
        },
    LogScaleCV {
            label: 'q'
            from: 1.0
            logBase: 2.5
            inVolts: inStream('q')
        }
    ]


}
