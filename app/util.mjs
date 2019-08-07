"use strict;"

global.forEach = (arr,fn) => {
    var len = arr.length;
    for (var i = 0; i < len; i++) {
        var ret = fn(arr[i],i);
        if (ret !== undefined)
            return ret;
    }
}

global.centerX = (rect) => rect.x + rect.width/2
global.centerY = (rect) => rect.y + rect.height/2
global.centerInX = (insideRect, outsideRect) => outsideRect.width/2 - insideRect.width/2;
global.centerInY = (insideRect, outsideRect) => outsideRect.height/2 - insideRect.height/2;

global.readFile = (fileUrl) => {
    if (fileUrl.startsWith('file:'))
        fileUrl = fileUrl.substr(5)
    if (fileUrl.startsWith('./'))
        fileUrl = fileUrl.substr(2)
    return HWIO.read(fileUrl)
}

global.writeFile = (fileUrl, contents) => HWIO.write(fileUrl, contents)

global.dbg = (obj) => {
    console.error(obj);
    for (var prop in obj)
    console.error("      "+prop+": "+obj[prop]);
}

global.uuids = {}
global.uuid = (cv) => {
    if (!uuids[cv])
        uuids[cv] = Object.keys(uuids).length + 1
    return uuids[cv];
}

global.clip = (min,v,max) => (v > max) ? max : ((v < min) ? min : v)

global.checked = (fn,extra) => {try { fn() } catch (err) { console.error(`

--- CHECKED EXCEPTION ---
   call:
      ${ fn.toString() + (extra?('\n      '+extra):'') }
   exception:
      ${ err.constructor.name }: ${ err.message }
   stack:
      ${ err.stack.split('\n').map(l=>'      '+l).join('\n') }

`)}}
