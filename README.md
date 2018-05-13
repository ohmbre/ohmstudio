# Ωhmstudio

Work-in-progress virtual modular synthesizer for audio and video.  Custom designed for ohmbre hardware synthesizer, a eurorack module with a touchscreen and analog-to-digital / vice-versa converters to play nicely with patching in and out of analog synthsizers.  Yet it is a fully standalone synthesis app easily portable to any Unix / Android / Mac / iOS / Windows / Browser platform because it's all written in QML / Javascript

### Build and Runtime Dependencies

* [Qt 5.11 Libs](https://www.qt.io/download-qt-installer) (Core, Gui, Quick, Multimedia, Network, Qml, QuickControls2, QuickTemplates2, Widgets)
* [Node.js](https://nodejs.org/en/)
* [Brig](https://github.com/BrigJS/brig)
* [node-speaker](https://github.com/TooTallNate/node-speaker)
* [threads.js](https://github.com/andywer/threads.js)

### Goals

* A high quality collection of base modules in terms of sound and performance (clocks, sequencers, oscillators, filters, VCAs, mixers, etc)
* A performant, lazy, metafunctional, multi-threaded runtime environment that squeezes all the performance it can out of embedded or portable devices.  This means streams get an internal mathematical representation up until we do something with them, like output to a soundcard, where each sample is calculated in a fast loop on a dedicated thread from a long functional chain. Then we can optimize by looking at the chains ahead of time to simplify them and remove or cache rendundant computation.  The software should also be able to pool the resources of multiple (possibly heterogenous) ohmbre devices to distribute load.
* Tight coupling to hardware inputs and outputs to have high quality external patching, yet any signal used in software can be routed in or out of the hardware to external modules, via control voltages, audio rate signals, USB MIDI, Bluetooth, etc 
* Ability to upload and share patches to a central database, as well as download patches and new modules contributed by fellow users and developers.
* Extremely extensible code model where new modules can be derived from base modules or their derivatives with a few lines of javascript or qml code
* Ability for non-developers to create and share modules too by a mode to export patches as meta-modules
* Slick, usable touch screen interface suitable for both music/video producting and live performance
* OpenGL visual canvas controlled by the same control or audio signals that can be used for music, routed straight out of the HDMI port through a GPU 
* Portability to other platforms, yet prioritized to use cases that integrate with and extend what should be a common singular and powerful platform. For example, browser-to-device integration is a priority for the near future.
* Open source software and low-cost or DIY commodity (yet specialized) open hardware, free of hindrance from (but often enhanced by) commercial interest.

If you would like to build your own Ωhmbre device, it's open hardware and DIY-able. The schematics, pcb design files, and build docs can be found over [here](https://github.com/ohmbre/ohmbre).

If you want to build the firmware, operating system, and userspace customized for the ohmbre hardware device to run this software, [get it](https://github.com/ohmbre/ohmwares) while it's hot. 

[![ohmbre](https://i.imgur.com/CpHEKZk.png)](https://vimeo.com/261403175 "Demo #1 - Toying with UI paradigm - click to watch")

