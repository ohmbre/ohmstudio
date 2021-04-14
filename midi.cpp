#include "midi.h"

static void anonCallback(double deltatime, std::vector<unsigned char> *message, void *userData = nullptr) {
   ((MIDIInFunc *) userData)->callback(deltatime, message);
}

QMap<quint8,QString> MIDIEvent::nibToType = {{0x9,"Note On"}, {0x8,"Note Off"}, {0xB,"Ctrl Change"}, {0xE,"Pitch Wheel"}};
QMap<QString,quint8> MIDIEvent::typeToNib = {{"Note On", 0x9}, {"Note Off",0x8}, {"Ctrl Change",0xB}, {"Pitch Wheel",0xE}};

Q_INVOKABLE MIDIInFunc::MIDIInFunc(QObject *parent): QObject(parent), gates(MIDIPOLY), vocts(MIDIPOLY), vels(MIDIPOLY),
    keyed(MIDIPOLY), keys(MIDIPOLY), keyPos(0) {
    lastEv = QVariant();
    for (int i = 0; i < MIDIPOLY; i++) {
        gates[i] = new MutableFunc();
        vocts[i] = new MutableFunc();
        vels[i] = new MutableFunc();
        keyed[i] = keys[i] = 0;
    }
}

Q_INVOKABLE MIDIInFunc::~MIDIInFunc() {
    for (int i = 0; i < MIDIPOLY; i++) {
        delete gates[i];
        delete vocts[i];
        delete vels[i];
    }
}

QStringList MIDIInFunc::listDevices() {
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

void MIDIInFunc::open(unsigned int portNum) {
    unsigned int nPorts = midiin.getPortCount();
    if (portNum >= nPorts) return;
    midiin.openPort( portNum );
    midiin.setCallback( &anonCallback, this );
    midiin.ignoreTypes( false, false, false );
}

Q_INVOKABLE QVariant MIDIInFunc::lastEvent() {
    return lastEv;
}

void MIDIInFunc::callback(double, std::vector<unsigned char> *message) {
    MIDIEvent ev(message->data(), (unsigned long) message->size());
    if (!chanFilter.contains(ev.channel)) return;
    if (!typeFilter.contains(ev.type)) return;
    if (!keyFilter.contains(ev.key)) return;
    lastEv = ev.asVariant();
    
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
        vocts[pos]->val = ((double)ev.key - 53.0)/12.0;
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

Q_INVOKABLE void MIDIInFunc::setJSCallback(QJSValue cb) {
    if (cb.isCallable()) jsCallback = cb;
}

Q_INVOKABLE void MIDIInFunc::setChanFilter(QVariantList chans) {
    chanFilter.clear();
    for (QVariant chan : chans)
        chanFilter.insert(chan.toInt()-1);
}

Q_INVOKABLE void MIDIInFunc::setTypeFilter(QStringList types) {
    typeFilter.clear();
    for(QString type : types) {
        if (MIDIEvent::typeToNib.contains(type))
            typeFilter.insert(MIDIEvent::typeToNib[type]);
    }
}

Q_INVOKABLE void MIDIInFunc::setKeyFilter(QVariantList keys) {
    keyFilter.clear();
    for(QVariant key : keys)
        keyFilter.insert(key.toInt());
}

