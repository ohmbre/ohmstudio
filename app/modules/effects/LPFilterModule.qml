import ohm 1.0

Module {
    objectName: 'LPFilterModule'

    label: 'LP Filter'

    property var alpha: `sinh(log(2)/2 * 1/@q * @f/sin(@f))`
    property var a0: `1 + sin(@f) * ${alpha}`
    property var a1: `-2 * cos(@f)`
    property var a2: `1 - sin(@f) * ${alpha}`
    property var b0: `(1 - cos(@f))/2`
    property var b1: `1 - cos(@f)`
    property var b2: `(1 - cos(@f))/2`

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
            logBase: 2
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
