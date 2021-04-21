# Ωhmstudio

Work-in-progress virtual modular synthesizer for audio and video, using just-in-time compilation to optimize signal processing.  Cross-platform support for linux, android, Mac OS X, iOS, Windows, and webassembly.  Written in C++17 / Javascript / QML.

### Build Dependencies

* [Qt 6.1 Libs](https://www.qt.io/download-qt-installer) (Core, Gui, Quick, Qml, QuickControls2)
* Other dependendencies are downloaded and built automatically (llvm, clang, and libgit2) 

### Features

* Lazy evaluation that chains ups function calls to be evaluated in real time at each interval of the audio interface sample rate. There is no buffering in between modules in the virtual synthesizer, which is atypical for digital audio processing, and this results in zero latency (except for the final output buffer that most audio interfaces will use).
* Very simple to design new modules, you simply supply a C/C++ function for each output jack that takes in the input jack voltages and returns the output voltage. Combine this with a couple lines of QML markup language for UI.
* The module's C++ code gets compiled at runtime by libclang/llvm and runs highly optimized and very fast.  For the most part, you can have as many modules cranking as your head can handle and your CPU won't break a sweat.
* A decent quality collection of base modules in terms of sound and performance (clocks, sequencers, oscillators, filters, VCAs, mixers, etc)
* Cross-platform software support for audio input/output interfaces and MIDI input/ouput devices.  Control voltages (CV) can be input/output over a DC-coupled audio interface currently.  In the future I want to support USB/SPI communication to data acqusition ADCs/DACs for CV, which dont behave like sound cards because each sample is input or output on demand from the software.
* Modules and revisions can be synced via local or remote GIT repositories (TODO)
* Programmable GPU shaders as output modules for visual/graphical synthesis from any input signals


