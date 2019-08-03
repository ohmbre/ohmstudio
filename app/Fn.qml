pragma Singleton
import QtQuick 2.11

QtObject {

    property var forEach: function (arr,fn) {
        var len = arr.length;
        for (var i = 0; i < len; i++) {
            var ret = fn(arr[i],i);
            if (ret !== undefined)
                return ret;
        }
    }

    property var centerX: function (rect) {
        return rect.x + rect.width/2
    }

    property var centerY: function (rect) {
        return rect.y + rect.height/2
    }

    property var centerInX: function (insideRect, outsideRect) {
        return outsideRect.width/2 - insideRect.width/2;
    }

    property var centerInY: function (insideRect, outsideRect) {
        return outsideRect.height/2 - insideRect.height/2;
    }

    property var readFile: function (fileUrl) {
        if (fileUrl.startsWith('file:'))
            fileUrl = fileUrl.substr(5)
        if (fileUrl.startsWith('./'))
            fileUrl = fileUrl.substr(2)
        return HWIO.read(fileUrl)
    }

    property var writeFile: function (fileUrl, contents) {
        return HWIO.write(fileUrl, contents)
    }

    property var dDump: function (obj) {
        console.error(obj);
        for (var prop in obj)
            console.error("      "+prop+": "+obj[prop]);
    }

    property var uuids: ({})
    property var uuid: function (cv) {
        if (!uuids[cv])
            uuids[cv] = Object.keys(uuids).length + 1
        return uuids[cv];
    }

    property var clip: function (min,v,max) {
        return (v > max) ? max : ((v < min) ? min : v)
    }

}
