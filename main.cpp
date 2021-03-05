#include "conductor.hpp"
#include "audio.hpp"
#include "scope.hpp"
#include "midi.hpp"
#include "dsp.hpp"
#include "external/tinycc/libtcc.h"



int main(int argc, char **argv) {
    return maestro.run(argc, argv);
}
