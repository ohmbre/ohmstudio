import QtQuick 2.10

QtObject {
    id: baseModel
    property QtObject parent
    property QtObject view
    /*Component.onCompleted: function() {
        function isModel(obj) {
            return obj !== null && (typeof obj) === "object" && (typeof obj.parent) != 'undefined';
        }
        for (var prop in baseModel) {
            if (prop === "view" || prop === "parent") continue;
            var obj = baseModel[prop];
            if (obj === null) continue;
            if (isModel(obj))
                obj.parent = baseModel;
            else if ((typeof obj.length) != 'undefined')
                for (var i = 0; i < obj.length; i++) {
                    var listObj = obj[i];
                    if (isModel(listObj))
                        listObj.parent = baseModel;
                }
            else { console.log("rejected - " + objectName + "." + prop); }
        }
    }*/
}
