import ohm.module 1.0
import ohm.jack.in 1.0

Module {
    objectName: "OutAudioHwModule"

    label: "Audio Out"

    outJacks: []

    inJacks: [
        InJack {label: "signal"}
    ]

    property int sampleRate: 48000
    property real samplePeriod: 1.0/sampleRate;

    pyLoops: []
    /*"
await sleep(1/self.property('sampleRate'))
volts = self.jack('signal').property('volts')
audio_out.write(FLOAT.pack(volts))
    "]*/
}
