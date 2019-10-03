#ifndef INCLUDE_CONDUCTOR_HPP
#define INCLUDE_CONDUCTOR_HPP

#include "common.hpp"
#include "sink.hpp"

class Conductor : public QObject {
    Q_OBJECT
public:
    static Conductor& instance() {
        static Conductor instance;
        return instance;
    }
    void registerSink(Sink *sink);
    void deregisterSink(Sink *sink);

    long long ticks;
    QThread thread;
    QElapsedTimer clock;
    QTimer *timer;
    QList<Sink*> sinks;
public slots:
    void start();
    void conduct();
private:
    Conductor();
    ~Conductor();
    Conductor(Conductor const&);
    void commit(Sink *sink);
    void operator=(Conductor const&);
};

#endif
