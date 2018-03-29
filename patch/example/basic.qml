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
    edges: [
        Edge {
            fromOutJack: modules[0].outJacks[0]
            toInJack: modules[1].inJacks[0]
        }
    ]
}
