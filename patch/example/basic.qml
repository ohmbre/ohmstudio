import ".."
import "../.."

Patch {
    id: basicPatch
    name: "example"

    modules: [
        ClockModule {},
        ClockModule {},
        GateHwModule {}
    ]
    cables: [
        Cable {
            out: modules[0].outJacks[0]
            inp: modules[1].inJacks[0]
        }
    ]
}
