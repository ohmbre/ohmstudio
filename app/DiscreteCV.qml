CV {
    id: discretecv
    property var step: 1
    property var start: -10
    property var end: 10
    unitStream: v => `(ceil((${start-step}+(${v}+10.000001)/20.000001*${end-start+step})/${step})*${step})`

}
