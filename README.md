# Ωhmstudio

Work-in-progress virtual modular synthesizer for audio and video.  Currently builds and works under linux, android, Mac OS X, iOS, Windows, and in the browser via webassembly.  Written in QML / Javascript / C++, it's main dependency is Qt and llvm/clang.

### Build and Runtime Dependencies

* [Qt 6.1 Libs](https://www.qt.io/download-qt-installer) (Core, Gui, Quick, Qml, QuickControls2)

### Features

* The virtual voltages are generated or transformed by modules and propagate over cables at discrete time steps, one-by-one, without buffers in between, which is atypical for audio processing
* Very simple to design new modules, you simply supply a C/C++ function that takes in the input voltages in real time and returns the output voltage.  Combine this with a couple lines of QML markup language for UI.
* A high quality collection of base modules in terms of sound and performance (clocks, sequencers, oscillators, filters, VCAs, mixers, etc)
* Cross-platform hardware interfaces for audio input/output and MIDI input/ouput.  CV can be input over a DC-coupled audio interface.
* Modules and revisions can be synced via local or remote GIT repositories (TODO)
* Progammable GPU shaders as modules to output visuals from input signals


