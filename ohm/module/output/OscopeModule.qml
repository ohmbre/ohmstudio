import QtQuick 2.11
import QtWebSockets 1.1

import ohm.ui 1.0
import ohm.module 1.0
import ohm.jack.in 1.0
import ohm.jack.out 1.0
import ohm.cv 1.0
import ohm.helpers 1.0

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
	    logBase: 1.585
	    inVolts: inStream('window')
	    from: '10ms'
	}
    ]

    property var ch1: inStream('ch1')
    property var ch2: inStream('ch2')
    property var vtrig: cvStream('vtrig')
    property var window: cvStream('window')
    property var streams: [ch1,ch2,vtrig,window]
    onStreamsChanged: engine.scope.msg({ cmd:'set', key:'streams', val:streams})

    Component.onCompleted: {
	if (!oscope.parent)
	    parentChanged.connect(function() {
		if (!oscope.parent.view)
		    oscope.parent.viewChanged.connect(function() {
			oscope.parent.view.moduleDisplay = scopeDisplay
		    });
		else oscope.parent.view.moduleDisplay = scopeDisplay
	    })
	else {
	    if (!oscope.parent.view)
		oscope.parent.viewChanged.connect(function() {
		    oscope.parent.view.moduleDisplay = scopeDisplay
		});
	    else oscope.parent.view.moduleDisplay = scopeDisplay
	}
    }
    
    property Component scopeDisplay: OhmScope {
	channelColors: ['#7df9ff', '#84ff8a']
	buffers: [new Int8Array(512), new Int8Array(512)]
	bgColor: 'transparent'
	trig: cvs[0].controlVolts * 12.7

	function enter() {
	    engine.scope.msg({ cmd:'set', key:'scopeEnabled', val:true })
	}

	function exit() {
	    engine.scope.msg({ cmd:'set', key:'scopeEnabled', val:false})
	}

	Connections {
	    target: engine.scope
	    onBinaryMessageReceived: function(msg) {
		var dataArray = new Int8Array(msg)
		var window = dataArray.length / 2
		for (var ch = 0; ch < 2; ch++) {
		    if (buffers[ch].length < window)
			buffers[ch] = new Int8Array(window)
		    buffers[ch].truncate = window
		}
		var d=0,b=0
		while (d < window) {
		    buffers[0][d] = dataArray[b++]
		    buffers[1][d++] = dataArray[b++]
		}
		requestPaint()
	    }
	}	
    }   
}    




