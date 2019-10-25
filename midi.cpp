#include "midi.hpp"

static void anonCallback(double deltatime, std::vector<unsigned char> *message, void *userData = nullptr) {
   ((MIDIInFunction *) userData)->callback(deltatime, message);
}

QMap<quint8,QString> MIDIEvent::nibToType = {{0x9,"Note On"}, {0x8,"Note Off"}, {0xB,"Ctrl Change"}, {0xE,"Pitch Wheel"}};
QMap<QString,quint8> MIDIEvent::typeToNib = {{"Note On", 0x9}, {"Note Off",0x8}, {"Ctrl Change",0xB}, {"Pitch Wheel",0xE}};

Q_INVOKABLE MIDIInFunction::MIDIInFunction(): QObject(QGuiApplication::instance()),
     gate1(0), gate2(0), gate3(0), voct1(0), voct2(0), voct3(0),
     vel1(0), vel2(0), vel3(0), cv(0), wheel(0), keyed({0,0,0}), keys({0,0,0}), keyPos(0)
{
    gates = {&gate1, &gate2, &gate3};
    vocts = {&voct1, &voct2, &voct3};
    vels = {&vel1, &vel2, &vel3};
}

QStringList MIDIInFunction::listDevices() {
    unsigned int nPorts = midiin.getPortCount();
    QStringList devList;
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
    if (!chanFilter.contains(ev.channel)) return;
    if (!typeFilter.contains(ev.type)) return;
    if (!keyFilter.contains(ev.key)) return;
    jsCallback.call(QJSValueList() << QQmlEngine::contextForObject(this)->engine()->toScriptValue(ev.asVariant()));
    int pos;

    if (ev.type == 0x9) {
        for (pos = 0; pos < MIDIPOLY; pos++)
            if (gates[pos]->val < 3)
                break;
        if (pos == MIDIPOLY) {
            int minkeyed = 99999999;
            int minpos = -1;
            for (pos = 0; pos < MIDIPOLY; pos++)
                if (keyed[pos] < minkeyed) {
                    minkeyed = keyed[pos];
                    minpos = pos;
                }
            pos = minpos;
        }
        vocts[pos]->val = ((V)ev.key - 53.0)/12.0;
        vels[pos]->val = ev.val / 127.0 * 10;
        gates[pos]->val = 10;
        keyed[pos] = ++keyPos;
        keys[pos] = ev.key;
    } else if (ev.type == 0x8) {
        for (pos = 0; pos < MIDIPOLY; pos++)
            if (keys[pos] == ev.key && gates[pos]->val > 3)
                break;
        if (pos == MIDIPOLY)
            qDebug() << "shouldnt be here";
        else
            gates[pos]->val = 0;
    } else if (ev.type == 0xB) {
        cv.val = ev.val / 127.0 * 20 - 10;
    } else if (ev.type == 0xE) {
        wheel.val = (((ev.key & 0x3f) << 8) & (ev.val)) / 16383.0 * 20 - 10;
    }
}

Q_INVOKABLE void MIDIInFunction::setJSCallback(QJSValue cb) {
    if (cb.isCallable()) jsCallback = cb;
}

Q_INVOKABLE void MIDIInFunction::setChanFilter(QVariantList chans) {
    chanFilter.clear();
    foreach (QVariant chan, chans)
        chanFilter.insert(chan.toInt()-1);
}

Q_INVOKABLE void MIDIInFunction::setTypeFilter(QStringList types) {
    typeFilter.clear();
    foreach(QString type, types) {
        if (MIDIEvent::typeToNib.contains(type))
            typeFilter.insert(MIDIEvent::typeToNib[type]);
    }
}

Q_INVOKABLE void MIDIInFunction::setKeyFilter(QVariantList keys) {
    keyFilter.clear();
    foreach(QVariant key, keys)
        keyFilter.insert(key.toInt());
}

