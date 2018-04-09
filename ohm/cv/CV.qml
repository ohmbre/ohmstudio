import ".."
model {
    objectName: "CV"

    property string label
    property double radix: 2
    property double valAtZero
    property double voltage: 0
    function val() {
        return valAtZero * Math.pow(radix, voltage)
    }
}
