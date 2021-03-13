#ifndef INCLUDE_CONDUCTOR_HPP
#define INCLUDE_CONDUCTOR_HPP

#define MAX_CHANNELS 32
#define PERIOD 2048
#define V double
#define Sample short
#define MAX_SINKS 64

class Function;
class RingBuf;
class Sink;
class AudioOut;

class Conductor : public QObject {
    Q_OBJECT

public:

    Conductor();
    ~Conductor();

    int run(int argc, char **argv);
    void background();

    quint64 ticks;
    V sym_s, sym_ms, sym_mins, sym_hz;

    AudioOut *audioOut;
    
    Q_INVOKABLE bool write(const QString &fname, const QString &content);
    Q_INVOKABLE QString read(const QString &fname);
    Q_INVOKABLE QString pwd();
    Q_INVOKABLE QVariant listDir(const QString &dname, const QString &match, const QString &base);
    Q_INVOKABLE QJSValue samplesFromFile(QUrl path);




};

inline Conductor maestro;


#endif
