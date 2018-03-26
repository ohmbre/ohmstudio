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
    connections: [
        Connection {
            fromOutJack: modules[0].outJacks[0]
            toInJack: modules[1].inJacks[0]
        }
    ]
}
