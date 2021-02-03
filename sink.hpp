#ifndef INCLUDE_SINK_HPP
#define INCLUDE_SINK_HPP

#include "conductor.hpp"
#include "function.hpp"


class Sink {
    Q_GADGET
public:
    Sink(int nchannels);
    Sink();
    ~Sink();
    virtual void flush() = 0;
    QVector<Function*> channels;
    int nchan() { return channels.count(); }
    bool registered;
    int bufpos;
    Sample *buf;
    void setChannelCount(int nchan);
    void sinkSetChannel(int i, QObject *function);
    long minPeriod, maxPeriod;

private:
    void operator=(Sink const&);
    Sink(Sink const&);
};




#endif
