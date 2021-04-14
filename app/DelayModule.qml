import QtQuick

Module {
    label: "Delay"

    InJack { label: 'signal' }
    InJack { label: 'inDelay' }

    CV {
        label: 'ctrlDelay'
        translate: v => 200 * 10**(v/10)
        unit: 'ms'
    }

    OutJack {
        label: 'delayed'
        calc: `long pos = 0;
               double history[768000];
               double calc() {
                   double ret = history[pos];
                   history[pos] = signal;
                   pos = (pos + 1) % (long) round(200*ms * pow(10., (inDelay + ctrlDelay)/10));
                   return ret;
               }`
    }

}
