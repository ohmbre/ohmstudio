
Patch {
    id: basicPatch
    name: "example"

    modules: [
        ClockModule {},
        GateHwModule {}
    ]
    connections: [
        Connection {
            fromOutJack: basicPatch.modules[0].outJacks[0]
            toInJack: basicPatch.modules[1].inJacks[0]
        }
    ]
}
