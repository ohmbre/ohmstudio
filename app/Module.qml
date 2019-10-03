import QtQuick 2.12

Model {
    id: mod
    property string label

    property list<InJack> inJacks
    property list<OutJack> outJacks
    property list<CV> cvs

    property var jacks: concatList(inJacks,outJacks)
    property var jackMap: arrayToObject(jacks.map(j => [j.label, j]))

    property int nJacks: jacks.length
    function jack(index) {
        return (typeof index == "number") ? jacks[index] : jackMap[index];
    }

    property var cvMap: arrayToObject(mapList(cvs,cv => [cv.label, cv]))
    function cv(index) {
        return (typeof index == "number") ? cvs[index] : cvMap[index];
    }


    property Component display: null
    property real x
    property real y
    property var view: null

    qmlExports: ({ objectName: 'objectName', x:'x', y:'y', cvs: 'default',})



    default property var contents
    onContentsChanged: {
        contents.parent = this;
        const typeMap = [['InJack', inJacks], ['OutJack', outJacks], ['CV', cvs]];
        typeMap.forEach(([type,container]) => {
            if (contents.objectName.endsWith(type)) {
                const cur = filterList(container, i => i.label === contents.label)
                if (cur.length) Object.keys(cur[0].qmlExports).forEach(key => { cur[0][key] = contents[key] })
                else container.push(contents);
            }
        });
    }





}
