
#ifndef INCLUDE_AUDIO_HPP
#define INCLUDE_AUDIO_HPP

#include "conductor.hpp"
#include "function.hpp"
#include "sink.hpp"

class Sink;

class AudioOut : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY changed)
    Q_PROPERTY(unsigned int sampleRate READ sampleRate WRITE setSampleRate NOTIFY changed)
public:
    AudioOut();
    ~AudioOut();
    
    Q_INVOKABLE QStringList availableDevs();
    Q_INVOKABLE void setChannel(int i, QObject *function);
    Q_INVOKABLE QString name();
    Q_INVOKABLE void setName(QString name);
    Q_INVOKABLE unsigned int sampleRate();
    Q_INVOKABLE void setSampleRate(unsigned int sampleRate);
    Q_INVOKABLE unsigned int period();
    Q_INVOKABLE unsigned int chCount();
    Q_INVOKABLE void addSink(Sink *sink);
    Q_INVOKABLE void removeSink(Sink *sink);    
    Q_INVOKABLE void pause();
    Q_INVOKABLE void resume();
    
    void reset();
    
signals:
    void changed();
    
private:    
    bool initialized;
    QList<Function*> channels;
    ma_context ctx;
    ma_device dev;
    V sinkBuf[4*PERIOD*sizeof(V)];
    QList<Sink*> sinks;

};

/*class AudioIn : public QIODevice {
    Q_OBJECT
public:
    Q_INVOKABLE AudioIn();
    ~AudioIn();
    qint64 writeData(const char *data, qint64 maxlen) override;
    qint64 readData(char *, qint64 ) override { return 0; };
    Q_INVOKABLE qint64 channelCount() { return channels.count(); }
    Q_INVOKABLE bool setDevice(const QString &name);
    Q_INVOKABLE Function* getChannel(int i);
    Q_INVOKABLE QStringList availableDevs();
    //QAudioInput *dev;
    QVector<BufferFunction*> channels;

};
*/



#endif
