#ifndef INCLUDE_SINK_HPP
#define INCLUDE_SINK_HPP

#include "conductor.hpp"
#include "function.hpp"

#define RINGBUFLEN 131072

class Sink {
    Q_GADGET
public:
    Sink(int nchannels);
    ~Sink();
    qint64 sinkChannelCount();
    virtual int writeData(Sample *buf, long long count) = 0;
    QVector<Function*> channels;
    Sample ringbuf[RINGBUFLEN];
    long long bi, bf;
    void sinkSetChannel(int i, QObject *function);
};




#endif
