import ohm.module 1.0
import ohm.jack.out 1.0
import ohm.jack.in 1.0
import ohm.helpers 1.0
import QtQuick 2.9
Module {
    objectName: "FunctionOscModule"
    label: "Function Osc"

    outJacks: [
        OutJack {id: signalOut; label: "signal"}
    ]

    inJacks: [
        InJack {id: voctIn; label: "v/oct"}
    ]

    // -10 <= func(t) <= 10
    // period sampled from [-1,t,1)
    property string waveFunction: "lambda t: 10*t"

    // all units in seconds, hz, etc
    property real period: 1.0/(Fn.noteToHz('C',0)*Math.pow(2, voctIn.volts))

    signal updateSignal(real v)
    onUpdateSignal: signalOut.volts = v

    pySetup: "
self.sample_rate = 48000
self.sample_period = 1./self.sample_rate
self.period = self.property('period')
self.wavefunc = eval(self.property('waveFunction'))
def updatePeriod():
  self.period = self.property('period')
self.periodChanged.connect(updatePeriod)
    "
    pyLoops: ["
runtime = get_event_loop().time()
t = (runtime/self.period - math.floor(runtime/self.period)) * 2 - 1
self.updateSignal.emit(self.wavefunc(t))
await sleep(self.sample_period)
    "]


    property Timer timer: Timer {
      interval: 500; running: true; repeat: true;
      onTriggered: console.log(signalOut.volts);
    }



}
