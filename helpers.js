
function centerX(rect) {
    return rect.x + rect.width/2
}

function centerY(rect) {
    return rect.y + rect.height/2
}

function centerRectX(insideRect, outsideRect) {
    return outsideRect.width/2 - insideRect.width/2;
}

function centerRectY(insideRect, outsideRect) {
    return outsideRect.height/2 - insideRect.height/2;
}

function dDump(obj) {
    console.log(obj);
    for (var prop in obj)
        console.log("      "+prop+": "+obj[prop]);
}
