#ifndef INCLUDE_CONDUCTOR_HPP
#define INCLUDE_CONDUCTOR_HPP

#define FRAMES_PER_SEC 48000
#define PERIOD 480
#define MAX_CHANNELS 8
#define V double
#define Sample short


class Sink;

#define maestro Conductor::instance()

class Conductor : public QThread {
    Q_OBJECT
public:
    static Conductor& instance() {
        static Conductor instance;
        return instance;
    }
    bool registerSink(Sink *sink);
    void deregisterSink(Sink *sink);
    void run() override;
    long long ticks;
    bool stopped;
    QElapsedTimer clock;
    QList<Sink*> sinks;
    void stop();
    void terminate();
    void resume();
    bool started;
    bool terminated;

private:
    Conductor();
    ~Conductor();

    Conductor(Conductor const&);
    void operator=(Conductor const&);

};

#endif
