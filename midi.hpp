#include "external/RtMidi.h"
#include "function.hpp"

class MIDIInFunction : public Function {
    Q_OBJECT
private:
    RtMidiIn midiin;
    QJSValue jsCallback;
    V curVal;

public:

    Q_INVOKABLE MIDIInFunction();

    Q_INVOKABLE QStringList listDevices();

    Q_INVOKABLE void open(unsigned int portNum);

    Q_INVOKABLE void setJSCallback(QJSValue cb);

    void callback(double deltatime, std::vector<unsigned char> *message);

    V eval() override;
    V operator()() override;
    Q_INVOKABLE QString repr() override;

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

    QVariant asVariant() {
        QMap<quint8,QString> typemap = {{0x8, "noteOn"}, {0x9, "noteOff"}, {0xA, "polyPressure"}, {0xB, "ctrlChange"}, {0xC, "progChange"},
                                        {0xD, "chanPressure"}, {0xE, "pitchWheel"}};
        QVariantMap obj = {};
        if (!typemap.contains(type)) return obj;
        obj["type"] = typemap[type];
        obj["channel"] = channel;
        obj["key"] = key;
        obj["val"] = val;
        return QVariant(obj);

    }
};
