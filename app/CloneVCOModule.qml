import QtQuick 2.15
import ohm 1.0

Module {

    id: cloneVco
    label: 'Clone VCO'

    InJack { label: 'input' }
    InJack { label: 'inFreq' }
    InJack { label: 'inGain' }
    CV {
        label: 'ctrlFreq'
        translate: v => 220 * 2**v
        unit: 'Hz'
    }
    CV { label: 'ctrlGain'; volts: 3 }

    Variable { label: 'f1'; value: Array(16).fill(0) }
    Variable { label: 'f2'; value: Array(16).fill(0) }
    Variable { label: 'v1';  value: Array(16).fill(0) }
    Variable { label: 'v2'; value: Array(16).fill(0) }
    Variable { label: 'p1'; value: Array(16).fill(0) }
    Variable { label: 'p2'; value: Array(16).fill(0) }

    OutJack {
        label: 'clone'
        expression:
            'var f := 220Hz * 2^(ctrlFreq + inFreq);
             p1[0] += f * f1[0];
             p1[1] += f * f1[1];
             p1[2] += f * f1[2];
             p1[3] += f * f1[3];
             p1[4] += f * f1[4];
             p1[5] += f * f1[5];
             p1[6] += f * f1[6];
             p1[7] += f * f1[7];
             p1[8] += f * f1[8];
             p1[9] += f * f1[9];
             p1[10] += f * f1[10];
             p1[11] += f * f1[11];
             p1[12] += f * f1[12];
             p1[13] += f * f1[13];
             p1[14] += f * f1[14];
             p1[15] += f * f1[15];
             p2[0] += f * f2[0];
             p2[1] += f * f2[1];
             p2[2] += f * f2[2];
             p2[3] += f * f2[3];
             p2[4] += f * f2[4];
             p2[5] += f * f2[5];
             p2[6] += f * f2[6];
             p2[7] += f * f2[7];
             p2[8] += f * f2[8];
             p2[9] += f * f2[9];
             p2[10] += f * f2[10];
             p2[11] += f * f2[11];
             p2[12] += f * f2[12];
             p2[13] += f * f2[13];
             p2[14] += f * f2[14];
             p2[15] += f * f2[15];
             (inGain + ctrlGain) * (v1[0]*sin(p1[0]) + v1[1]*sin(p1[1]) + v1[2]*sin(p1[2]) + v1[3]*sin(p1[3]) + v1[4]*sin(p1[4]) + v1[5]*sin(p1[5]) + v1[6]*sin(p1[6]) + v1[7]*sin(p1[7]) + v1[8]*sin(p1[8]) + v1[9]*sin(p1[9]) + v1[10]*sin(p1[10]) + v1[11]*sin(p1[11]) + v1[12]*sin(p1[12]) + v1[13]*sin(p1[13]) + v1[14]*sin(p1[14]) + v1[15]*sin(p1[15]) + v2[0]*sin(p2[0]) + v2[1]*sin(p2[1]) + v2[2]*sin(p2[2]) + v2[3]*sin(p2[3]) + v2[4]*sin(p2[4]) + v2[5]*sin(p2[5]) + v2[6]*sin(p2[6]) + v2[7]*sin(p2[7]) + v2[8]*sin(p2[8]) + v2[9]*sin(p2[9]) + v2[10]*sin(p2[10]) + v2[11]*sin(p2[11]) + v2[12]*sin(p2[12]) + v2[13]*sin(p2[13]) + v2[14]*sin(p2[14]) + v2[15]*sin(p2[15]))'
    }

    property var bins: null
    property var fourier: new Fourier()


    function argrelextrema(data,order) {
        let i
        const dlen = data.length
        let results = Array(dlen).fill(true)
        const dataclip = i => i >= data.length ? data[data.length-1] : (i < 0 ? data[0] : data[i])
        for (let shift = 1; shift < order+1; shift++) {
            for (i = 0; i < data.length; i++) {
                if (data[i] < dataclip(i+shift)) results[i] = false;
                if (data[i] < dataclip(i-shift)) results[i] = false;
            }
        }
        let globmax = 0
        let globmaxi = -1
        for (i = 0; i < data.length; i++)
            if (data[i] > globmax) {
                globmax = data[i]
                globmaxi = i;
            }
        for (i = 0; i < data.length; i++)
            if (i < globmaxi || data[i] < 0.001*globmax) results[i] = false;
        const idxs = []
        for (i = 0; i < data.length; i++)
            if (results[i]) idxs.push(i)
        return idxs
    }


    onBinsChanged: {
        if (bins === null) return;
        let mags = [];
        for (let i = 1; i < 2048; i++)
            mags.push(bins[i]**2 + bins[4096-i]**2)
        const idxs = argrelextrema(mags,5).slice(0,16).map(idx=>idx+1)
        const norm = 4096/(2*Math.PI) //idxs[0]
        const f1 = idxs.map(idx => idx/norm)
        const f2 = idxs.map(idx => (4096-idx)/norm)
        const v1 = idxs.map(idx => bins[idx])
        const v2 = idxs.map(idx => bins[4096-idx])
        const vars = [f1,f2,v1,v2]
        vars.forEach(v => { while (v.length < 16) v.push(0) })

        variable('f1').value = f1
        variable('f2').value = f2
        variable('v1').value = v1
        variable('v2').value = v2

        debug = f1.map((f,i) => `${Math.round(f*1000)/1000}`).join(', ')
    }

    property var debug: ''

    Component.onCompleted: {
        if (cloneVco.jack('input').inFunc)
            fourier.setChannel(0, cloneVco.jack('input').inFunc);
        cloneVco.jack('input').inFuncUpdated.connect((lbl,func) => { cloneVco.fourier.setChannel(0, func) })
    }

    display: Item {
        anchors.fill: parent
        OhmButton {
            text: "clone"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: cloneVco.bins = cloneVco.fourier.getBins();
        }
        OhmText {
            anchors.fill: parent
            color: 'black'
            font.pixelSize: 6
            text: cloneVco.debug
        }
    }
}





