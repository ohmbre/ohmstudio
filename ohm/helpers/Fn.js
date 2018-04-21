.pragma library

function centerX(rect) {
    return rect.x + rect.width/2
}

function centerY(rect) {
    return rect.y + rect.height/2
}

function centerInX(insideRect, outsideRect) {
    return outsideRect.width/2 - insideRect.width/2;
}

function centerInY(insideRect, outsideRect) {
    return outsideRect.height/2 - insideRect.height/2;
}

function readFile(fileUrl) {
    var request = new XMLHttpRequest();
    request.open("GET", fileUrl, false);
    request.send(null);
    return request.responseText;
}

function writeFile(fileUrl, contents) {
    var request = new XMLHttpRequest();
    request.open("PUT", fileUrl, false);
    request.send(contents);
}


function dDump(obj) {
    console.warn(obj);
    for (var prop in obj)
        console.warn("      "+prop+": "+obj[prop]);
}

var noteOffsets = {'C': -9,
                   'C#': -8, 'Db': -8,
                   'D': -7,
                   'D#': -6, 'Eb': -6,
                   'E': -5,
                   'F': -4,
                   'F#': -3, 'Gb': -3,
                   'G': -2,
                   'G#': -1, 'Ab': -1,
                   'A': 0,
                   'A#': 1, 'Bb': 1,
                   'B': 2 };

// noteOffset('A',4) = 0
function noteOffset(note,octave) {
  return (octave - 4) * 12 + noteOffsets[note];
}

// noteToHz('A',0) = 440
function noteToHz(note, octave) {
  return 440*Math.pow(Math.pow(2,1.0/12), noteOffset(note,octave));
}
