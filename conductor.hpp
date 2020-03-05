#ifndef INCLUDE_CONDUCTOR_HPP
#define INCLUDE_CONDUCTOR_HPP

constexpr auto FRAMES_PER_SEC = 48000;
constexpr auto MIN_PERIOD = 960;
constexpr auto MAX_PERIOD = 7680;
constexpr auto MAX_CHANNELS = 8;
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
    long period,minPeriod,maxPeriod;
    bool stopped;
    QElapsedTimer clock;
    QList<Sink*> sinks;
    void stop();
    void resume();
    void adjustPeriod();
    bool started;

private:
    Conductor();
    ~Conductor();
    void computePeriod();

    Conductor(Conductor const&);
    void operator=(Conductor const&);

};

#endif
