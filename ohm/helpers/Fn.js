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

function aContainsB(a, b) {
    return (a.x < b.x) && (a.y < b.y) && ((a.x + a.width) > (b.x + b.width)) && ((a.y + a.height) > (b.y + b.height));
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



