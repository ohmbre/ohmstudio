#include "conductor.hpp"
#include "function.hpp"
#include "sink.hpp"

Conductor::Conductor() :
    QThread(), ticks(0), period(MIN_PERIOD), minPeriod(MIN_PERIOD), maxPeriod(MAX_PERIOD),
    stopped(true), clock(), started(false), terminated(false) {}


void Conductor::run() {
    started = true;

    QElapsedTimer clock;
    clock.start();

    setPriority(QThread::TimeCriticalPriority);

    double nsecs_per_frame = 1000000000.0 / FRAMES_PER_SEC;
    long long niter = 0;
    int nchan,c,t;
    stopped = false;
    while (!stopped) {
        long long nsecs = period * nsecs_per_frame * niter - clock.nsecsElapsed();
        if (nsecs > 0) {
            QThread::usleep(nsecs/1000);
        }

        Function *func;

        Sink *sink;
        foreach(sink, sinks)
            sink->bufpos = 0;
        for (t = 0; t < period; t++) {
            foreach(sink, sinks) {
                nchan = sink->nchan();
                for (c = 0; c < nchan; c++) {
                    func = sink->channels[c];
                    sink->buf[sink->bufpos++] = func ? qRound(qBound(-10.0,(*func)(),10.0)*3276.7) : 0;
                }
            }
            this->ticks++;
        }
        foreach(sink, sinks)
            sink->flush();
        niter++;
    }


}

void Conductor::stop() {
    if (stopped) return;
    if (!started) return;
    stopped = true;
    wait();

}

void Conductor::terminate() {
    stop();
    terminated = true;
}

void Conductor::resume() {
    if (started && stopped && !terminated) start();
}

Conductor::~Conductor() {
}

void Conductor::adjustPeriod() {
    period = minPeriod;
    foreach(Sink *sink, sinks) {
        if (sink->buf != nullptr)
            delete sink->buf;
        sink->buf = new Sample[sink->nchan() * period];
    }
}

bool Conductor::registerSink(Sink *sink) {

    if (sink->registered) return false;
    if (sink->minPeriod > maxPeriod) return false;
    if (sink->maxPeriod < minPeriod) return false;
    stop();
    sink->registered = true;
    sinks.append(sink);
    if (sink->minPeriod > minPeriod) minPeriod = sink->minPeriod;
    if (sink->maxPeriod < maxPeriod) maxPeriod = sink->maxPeriod;
    adjustPeriod();
    resume();
    return true;
}

void Conductor::deregisterSink(Sink *sink) {
    if (!sink->registered) return;
    stop();
    sink->registered = false;
    sinks.removeAll(sink);
    maxPeriod = MAX_PERIOD;
    minPeriod = MIN_PERIOD;
    foreach (Sink *s, sinks) {
        if (s->minPeriod > minPeriod) minPeriod = s->minPeriod;
        if (s->maxPeriod < maxPeriod) maxPeriod = s->maxPeriod;
    }
    adjustPeriod();
    resume();
}
