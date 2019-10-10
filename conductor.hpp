#ifndef INCLUDE_CONDUCTOR_HPP
#define INCLUDE_CONDUCTOR_HPP

constexpr auto FRAMES_PER_SEC = 48000;
constexpr auto FRAMES_PER_NSEC = 0.000048;
constexpr auto BYTES_PER_SAMPLE = 2;
constexpr auto FRAMES_PER_PERIOD = 3840;
constexpr auto MSEC_PER_PERIOD = FRAMES_PER_PERIOD / 48;
constexpr auto MAX_CHANNELS = 8;
#define V double
#define Sample short



class Sink;





#define maestro Conductor::instance()

class Conductor : public QObject {
    Q_OBJECT
public:
    static Conductor& instance() {
        static Conductor instance;
        return instance;
    }
    void registerSink(Sink *sink);
    void deregisterSink(Sink *sink);
    void setEngine(QQmlApplicationEngine *e) { engine = e; }

    long long ticks;
    QThread thread;
    QQmlApplicationEngine *engine;
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
