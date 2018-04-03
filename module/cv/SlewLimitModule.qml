import ".."
import "../.."
Module {
    objectName: "SlewLimitModule"

    label: "SlewLimit"

    outJacks: [
        OutJack {label: "slewed"}
    ]

    inJacks: [
        InJack {label: "limit"},
        InJack {label: "signal"}

    ]
}

