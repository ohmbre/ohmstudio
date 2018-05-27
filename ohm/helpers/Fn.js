.pragma library

function forEach(arr,fn) {
    var len = arr.length, i, ret;
    for (i = 0; i < len; i++) {
	var ret = fn(arr[i],i);
	if (ret !== undefined)
	    return ret;
    }
}

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

function interArea(a, b) {
    var xOverlap = Math.max(0, Math.min(a.x + a.width, b.x + b.width) - Math.max(a.x, b.x));
    var yOverlap = Math.max(0, Math.min(a.y + a.height, b.y + b.height) - Math.max(a.y, b.y));
    return xOverlap * yOverlap;
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
    console.error(obj);
    for (var prop in obj)
        console.error("      "+prop+": "+obj[prop]);
}



