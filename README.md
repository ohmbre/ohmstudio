# Ωhmstudio

Work-in-progress virtual modular synthesizer for audio and video.  Custom designed for ohmbre hardware synthesizer, a eurorack module with a touchscreen and analog-to-digital / vice-versa converters to play nicely with patching in and out of analog synthsizers.  Yet it is easily portable to any Unix / Android / Mac / iOS / Windows / Browser platform thanks to the qml language it uses.

### Build and Runtime Dependencies

* [Qt Libraries and Headers](https://www.qt.io/download-qt-installer) (run using `qmlscene View.qml`)
* Additionally it can be compiled and run using a C++ compiler and qbs build tools (best use [gcc](https://gcc.gnu.org/) for linux-based platforms, [llvm](http://releases.llvm.org/download.html) for Mac/iOS) `qbs install`
* Alternatively, you can run it with [Python](https://www.python.org/downloads/Python) and [PySide](https://wiki.qt.io/PySide2_GettingStarted) Qt bindings using `python main.py`

### Goals

* A high quality collection of base modules in terms of sound and performance (clocks, sequencers, oscillators, filters, VCAs, mixers, etc)
* A state-of-the-art event-driven, multi-threaded runtime environment that squeezes all the performance it can out of embedded or portable devices.  This includes both an intelligent routing supervisor that can analyze and work around the weakest links to keep latency and artifacts to a minimum, and an communicative interface between modules and even chains of modules that reduces the potential for bottlenecks.
* Tight coupling to hardware inputs and outputs to have high quality external patching, yet any signal used in software can be routed in or out of the hardware to external modules, via control voltages, audio rate signals, USB MIDI, Bluetooth, etc 
* Ability to upload and share patches to a central database, as well as download patches and new modules contributed by fellow users and developers.
* Extremely extensible code model where new modules can be derived from base modules or their derivatives with a few lines of python or qml code
* Ability for non-developers to create and share modules too by a mode to export patches as meta-modules
* Slick, usable touch screen interface suitable for both music/video producting and live performance
* OpenGL visual canvas controlled by the same control or audio signals that can be used for music, routed straight out of the HDMI port through a GPU 

[![ohmbre](https://i.imgur.com/CpHEKZk.png)](https://vimeo.com/261403175 "Demo #1 - Toying with UI paradigm - click to watch")

