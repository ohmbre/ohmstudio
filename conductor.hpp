#ifndef INCLUDE_CONDUCTOR_HPP
#define INCLUDE_CONDUCTOR_HPP

#define MAX_CHANNELS 32
#define PERIOD_ASK 2048
#define V double
#define Sample short

class Function;

class Conductor : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString outputName READ outputName WRITE setOutputName NOTIFY outputChanged)
    Q_PROPERTY(unsigned int sampleRate READ sampleRate WRITE setSampleRate NOTIFY outputChanged)

public:

    Conductor();
    ~Conductor();

    int run(int argc, char **argv);
    void resetOutput();

    Q_INVOKABLE QString outputName() {
        return QString(outDev.playback.name);
    }

    Q_INVOKABLE unsigned int sampleRate() {
        return outDev.sampleRate;
    }

    Q_INVOKABLE unsigned int outputChCount() {
        return outDev.playback.channels;
    }

    Q_INVOKABLE unsigned int period() {
        return outDev.playback.internalPeriodSizeInFrames;
    }

    Q_INVOKABLE void setOutputName(QString name) {
        settings->setValue("outputName", name);
        resetOutput();
    }

    Q_INVOKABLE void setSampleRate(unsigned int sampleRate) {
        settings->setValue("sampleRate", sampleRate);
        resetOutput();
    }


    Q_INVOKABLE QStringList availableDevs();
    Q_INVOKABLE void setChannel(int i, QObject *function);
    quint64 ticks;
    V sym_s, sym_ms, sym_mins, sym_hz;


    Q_INVOKABLE bool write(const QString &fname, const QString &content);
    Q_INVOKABLE QString read(const QString &fname);
    Q_INVOKABLE QString pwd();
    Q_INVOKABLE QVariant listDir(const QString &dname, const QString &match, const QString &base);
    Q_INVOKABLE QJSValue samplesFromFile(QUrl path);

signals:
    void outputChanged();


private:
    ma_context audioContext;
    ma_device outDev;
    Function* channelMap[MAX_CHANNELS];
    QGuiApplication *qapp;
    QQmlApplicationEngine *engine;
    QSettings *settings;
    QJSValue gui;
    QMutex mutex;

};


inline Conductor maestro;

#endif
