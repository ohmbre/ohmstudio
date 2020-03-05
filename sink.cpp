#include "sink.hpp"

Sink::Sink(int nchannels) : channels(), registered(false),
    bufpos(0), buf(nullptr), minPeriod(MIN_PERIOD), maxPeriod(MAX_PERIOD)
{
    channels.resize(nchannels);
    for (int i = 0; i < nchannels; i++)
        channels[i] = nullptr;
}


Sink::~Sink() {
    maestro.deregisterSink(this);
    for (int i = 0; i < nchan(); i++)
        channels[i] = nullptr;
}

void Sink::setChannelCount(int n) {
    if (registered) {
        qDebug() << "ERROR CANNOT SET SINK CHANNEL COUNT AFTER REGISTERING";
        return;
    }
    channels.resize(n);
    for (int i = 0; i < n; i++)
        channels[i] = nullptr;
    buf = new Sample[n*maestro.period];
}

void Sink::sinkSetChannel(int i, QObject *function) {
    if (i < 0 || i >= nchan()) {
        qDebug() << "tried to set function for invalid channel" << i;
        return;
    }
    maestro.stop();
    if (function == nullptr) channels[i] = nullptr;
    else channels[i] = qobject_cast<Function*>(function);
    maestro.resume();
}
