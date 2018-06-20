import QtQuick 2.11

import ohm.ui 1.0
import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.cv 1.0
import ohm.helpers 1.0
import Brig.SinkThread 1.0

Module {

    id: oscope
    objectName: 'OscopeModule'
    label: 'Scope'

    inJacks: [
        InJack { label: 'ch1' },
	InJack { label: 'ch2' },
	InJack { label: 'vtrig' },
	InJack { label: 'window' }
    ]

    cvs: [
	LinearCV {
	    label: 'vtrig'
	    inVolts: inStream('vtrig')
	    from: 0
	},
	LogScaleCV {
	    label: 'window'
	    logBase: 1.7
	    inVolts: inStream('window')
	    from: '10ms'
	}
    ]
	    

    property var ch1: inStream('ch1')
    property var ch2: inStream('ch2')
    property var vtrig: cvStream('vtrig')
    property var window: cvStream('window')
    property var streams: [ch1,ch2,vtrig,window]
    property var changes: [ch1Changed,ch2Changed,vtrigChanged,windowChanged]

    property Component threadComponent: SinkThread {
	function callback(ch1,ch2,calcWindow) {
	    const ch1data = ch1.split(',')
	    const ch2data = ch2.split(',')
	    scopeWindow = calcWindow
	    scopeBuffers = [ch1data, ch2data]
        }
    }

    function updateThread() {
	thread.sendMessage(JSON.stringify({cmd:'set',key:'streams', val:streams}))
    }

    property SinkThread thread
    
    function enterCloseup() {
	var incubator = threadComponent.incubateObject(oscope, {}, Qt.Synchronous)
	thread = incubator.object
	for (var s=0; s < streams.length; s++)
	    changes[s].connect(updateThread)
	updateThread()
	thread.sendMessage(JSON.stringify({cmd:'set',key:'scopeEnabled',val:true}))
    }

    function exitCloseup() {
	for (var s=0; s < streams.length; s++)
	    changes[s].disconnect(updateThread)
	thread.kill()
    }

    property var scopeBuffers: [new Int8Array(512), new Int8Array(512)]
    property string scopeWindow: ''

    closeupDisplay: OhmScope {
	channelColors: ['#7df9ff', '#84ff8a']
	buffers: scopeBuffers
	window: (Math.round(scopeWindow/4.8)/10)+'ms'
	bgColor: 'transparent'
	trig: cvs[0].controlVolts * 12.7
	Component.onCompleted: {
	    oscope.scopeBuffersChanged.connect(requestPaint)
	}
	    
    }    


}


