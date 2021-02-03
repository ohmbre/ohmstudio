#include "conductor.hpp"
#include "function.hpp"
#include "sink.hpp"

Conductor::Conductor() : QThread(), ticks(0), stopped(true), clock(), started(false), terminated(false) {}


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
        long long nsecs = PERIOD * nsecs_per_frame * niter - clock.nsecsElapsed();
        if (nsecs > 0) {
            QThread::usleep(nsecs/1000);
        }

        Function *func;

        Sink *sink;
        foreach(sink, sinks)
            sink->bufpos = 0;
        for (t = 0; t < PERIOD; t++) {
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

Conductor::~Conductor() {}

bool Conductor::registerSink(Sink *sink) {

    if (sink->registered) return false;
    stop();
    if (sink->buf != nullptr) delete sink->buf;
    sink->buf = new Sample[sink->nchan() * PERIOD];
    for (int s = 0; s < PERIOD * sink->nchan(); s++) sink->buf[s] = 0;
    sink->registered = true;
    sinks.append(sink);
    resume();
    return true;
}

void Conductor::deregisterSink(Sink *sink) {
    if (!sink->registered) return;
    stop();
    sink->registered = false;
    sinks.removeAll(sink);
    resume();
}
