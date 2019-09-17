CV {
    id:lincv
    objectName: 'LinearCV'

    property var offset: null
    unitStream: v => offset ? `(${offset} + ${v})` : v
}
