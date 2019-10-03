import ohm 1.0

Module {
    label: "Multiple"

        OutJack {
            label: "out1"
            stream: inStream('in')
        }
        OutJack {
            label: "out2"
            stream: inStream('in')
        }
        OutJack {
            label: "out3"
            stream: inStream('in')
        }
        OutJack {
            label: "out4"
            stream: inStream('in')
        }



        InJack {
            label: "in";
        }


}
