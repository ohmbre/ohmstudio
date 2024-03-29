#pragma once

#include <QObject>

#include "external/RtMidi.h"
#include "func.h"

#define MIDIPOLY 3

class MIDIInFunc : public QObject {
    Q_OBJECT
private:
    RtMidiIn midiin;
    QJSValue jsCallback;
    QSet<int> chanFilter;
    QSet<int> typeFilter;
    QSet<int> keyFilter;
    MutableFunc cv, wheel;
    QVector<MutableFunc*> gates, vocts, vels;
    QVector<int> keyed;
    QVector<int> keys;
    int keyPos;
    QVariant lastEv;
    
public:

    Q_INVOKABLE MIDIInFunc(QObject *parent = nullptr);
    Q_INVOKABLE ~MIDIInFunc();

    Q_INVOKABLE QStringList listDevices();

    Q_INVOKABLE void open(unsigned int portNum);

    Q_INVOKABLE void setJSCallback(QJSValue cb);
    Q_INVOKABLE void setChanFilter(QVariantList chans);
    Q_INVOKABLE void setTypeFilter(QStringList types);
    Q_INVOKABLE void setKeyFilter(QVariantList keys);

    void callback(double deltatime, std::vector<unsigned char> *message);


    Q_INVOKABLE QFunc* getGate(int n) { return gates[n%MIDIPOLY]; }
    Q_INVOKABLE QFunc* getVoct(int n) { return vocts[n%MIDIPOLY]; }
    Q_INVOKABLE QFunc* getVel(int n) { return vels[n%MIDIPOLY]; }
    Q_INVOKABLE QFunc* getCv() { return &cv; }
    Q_INVOKABLE QFunc* getWheel() { return &wheel; }
    
    Q_INVOKABLE QVariant lastEvent();
    

};

class MIDIEvent {
public:
    quint8 type;
    quint8 channel;
    quint8 key;
    quint8 val;

    MIDIEvent(quint8 *data, unsigned long len) {
        if (len > 0) {
            type = data[0] >> 4;
            channel = data[0] & 0xF;
        }
        if (len > 1)
            key = data[1];
        if (len > 2)
            val = data[2];
    }

    static QMap<quint8,QString> nibToType;
    static QMap<QString,quint8> typeToNib;

    QVariant asVariant() {
        QVariantMap obj = {};
        if (!nibToType.contains(type)) return obj;
        obj["type"] = nibToType[type];
        obj["channel"] = channel;
        obj["key"] = key;
        obj["val"] = val;
        return QVariant(obj);

    }
};

