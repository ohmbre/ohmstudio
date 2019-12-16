
#ifndef INCLUDE_AUDIO_HPP
#define INCLUDE_AUDIO_HPP

#include "conductor.hpp"
#include "function.hpp"
#include "sink.hpp"





class AudioOut : public QObject, public Sink {
    Q_OBJECT
public:
    Q_INVOKABLE AudioOut();
    ~AudioOut();
    int writeData(Sample *buf, long long count) override;
    Q_INVOKABLE qint64 channelCount();
    Q_INVOKABLE void setChannel(int i, QObject *function);
    Q_INVOKABLE void setDevice(const QString &name);
    Q_INVOKABLE QStringList availableDevs();
    QAudioOutput *dev;
    QIODevice *iodev;
};




class AudioIn : public QIODevice {
    Q_OBJECT
public:
    Q_INVOKABLE AudioIn();
    ~AudioIn();
    qint64 writeData(const char *data, qint64 maxlen) override;
    qint64 readData(char *, qint64 ) override { return 0; };
    Q_INVOKABLE qint64 channelCount();
    Q_INVOKABLE void setDevice(const QString &name);
    Q_INVOKABLE Function* getChannel(int i);
    Q_INVOKABLE QStringList availableDevs();
    QAudioInput *dev;
    QVector<BufferFunction*> channels;
};


#endif
