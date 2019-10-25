#include "conductor.hpp"
#include "function.hpp"
#include "sink.hpp"

Conductor::Conductor() : QObject(QGuiApplication::instance()), ticks(0), timer(nullptr) {}

void Conductor::start() {
    timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &Conductor::conduct);


    timer->start(MSEC_PER_PERIOD);
    clock.start();
}

void Conductor::conduct() {
    qint64 nticks = floor(clock.nsecsElapsed() * FRAMES_PER_NSEC);
    clock.restart();

    Function *func;
    int nchan,c,t;
    Sink *sink;
    for (t = 0; t < nticks; t++) {
        foreach(sink, sinks) {
            nchan = sink->channels.count();
            for (c = 0; c < nchan; c++) {
                func = sink->channels[c];
                sink->ringbuf[sink->bf++ % RINGBUFLEN] = func ? qRound(qBound(-10.0,(*func)(),10.0)*3276.7) : 0;
            }
        }
        this->ticks++;
    }
    foreach(sink, sinks)
        commit(sink);

}

void Conductor::commit(Sink *sink) {
    if ((sink->bf - sink->bi) >= RINGBUFLEN) {
        qDebug() << "ran out of audio buffer space, discarding samples";
        sink->bi = sink->bf - RINGBUFLEN;
    }

    while (true) {
        int towrite = qMin(RINGBUFLEN - sink->bi % RINGBUFLEN, sink->bf - sink->bi);
        if (!towrite) break;
        int written = sink->writeData(sink->ringbuf + sink->bi % RINGBUFLEN, towrite);
        sink->bi += written;
        if (!written) break;
    }
}

Conductor::~Conductor() {
    timer->stop();
    thread.quit();
    delete timer;
}


void Conductor::registerSink(Sink *sink) {
    sinks.append(sink);
}


void Conductor::deregisterSink(Sink *sink) {
    instance().sinks.removeAll(sink);
}
