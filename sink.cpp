#include "sink.hpp"

Sink::Sink(int nchannels) : channels(nchannels), bi(0), bf(0) {
    for (int i = 0; i < nchannels; i++)
        channels[i] = nullptr;
}

Sink::~Sink() {
    maestro.deregisterSink(this);
    for (int i = 0; i < channels.count(); i++)
        channels[i] = nullptr;
}

qint64 Sink::sinkChannelCount() { return channels.count(); }
void Sink::sinkSetChannel(int i, QObject *function) {
    if (i < 0 || i >= channels.count()) {
        qDebug() << "tried to set function for invalid channel" << i;
        return;
    }
    if (function == nullptr) channels[i] = nullptr;
    else channels[i] = qobject_cast<Function*>(function);

}
