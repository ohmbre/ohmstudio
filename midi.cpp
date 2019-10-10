#include "midi.hpp"

static void anonCallback(double deltatime, std::vector<unsigned char> *message, void *userData = nullptr) {
   ((MIDIInFunction *) userData)->callback(deltatime, message);
}

Q_INVOKABLE MIDIInFunction::MIDIInFunction(): Function(), curVal(0) {
}

QStringList MIDIInFunction::listDevices() {
    unsigned int nPorts = midiin.getPortCount();
    QStringList devList;
    qDebug() << nPorts << "midi ports";
    for (unsigned int i = 0; i < nPorts; i++) {
        try { devList << QString::fromStdString(midiin.getPortName(i)); }
        catch ( RtMidiError &error ) {
            devList << QString::fromStdString(error.getMessage());
            qDebug() << "Error querying MIDI ports:" << QString::fromStdString(error.getMessage());
        }
    }
    return devList;
}

void MIDIInFunction::open(unsigned int portNum) {
    midiin.openPort( portNum );
    midiin.setCallback( &anonCallback, this );
    //midiin->ignoreTypes( false, false, false );
}

void MIDIInFunction::callback(double, std::vector<unsigned char> *message) {
    MIDIEvent ev(message->data(), message->size());
    jsCallback.call(QJSValueList() << maestro.engine->toScriptValue(ev.asVariant()));
    if (ev.type == 0x9) curVal = ((V)ev.key - 53.0)/12.0;
    if (ev.type == 0xB) curVal = ev.val / 127.0 * 20 - 10;
}

Q_INVOKABLE void MIDIInFunction::setJSCallback(QJSValue cb) {
    if (cb.isCallable()) jsCallback = cb;
}

V MIDIInFunction::eval() { return curVal; }
V MIDIInFunction::operator()() { return curVal; }
Q_INVOKABLE QString MIDIInFunction::repr() { return "MidiFunction()"; }
