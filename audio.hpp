
#ifndef INCLUDE_AUDIO_HPP
#define INCLUDE_AUDIO_HPP

#include "common.hpp"
#include "function.hpp"
#include "sink.hpp"

class AudioIn : public QIODevice {
    Q_OBJECT
public:
    AudioIn(QAudioDeviceInfo info);
    ~AudioIn();
    qint64 writeData(const char *data, qint64 maxlen) override;
    qint64 readData(char *, qint64 ) override { return 0; };
    Q_INVOKABLE qint64 channelCount() { return channels.count(); }

    QAudioInput *dev;
    QAudioDeviceInfo devInfo;
    QVector<BufferFunction*> channels;
public slots:
    void start();
};



class AudioOut : public QObject, public Sink {
    Q_OBJECT
public:
    AudioOut(QAudioDeviceInfo info);
    ~AudioOut();
    int writeData(Sample *buf, long long count) override;
    Q_INVOKABLE qint64 channelCount() { return sinkChannelCount(); }
    Q_INVOKABLE void setChannel(int i, QObject *function) { sinkSetChannel(i, function); }

    QAudioOutput *dev;
    QAudioDeviceInfo devInfo;
    QIODevice *iodev;
};



class AudioHWInfo : public QObject {
    Q_OBJECT
public:
    AudioHWInfo();
    Q_INVOKABLE AudioOut* createOutput(QString devName);
    Q_INVOKABLE AudioIn* createInput(QString devName);
    static QAudioFormat getFormat();
    static QStringList availableDevs(QAudio::Mode mode);
    Q_INVOKABLE static QStringList availableInDevs();
    Q_INVOKABLE static QStringList availableOutDevs();
    static QAudioDeviceInfo devInfo(QString name, QAudio::Mode mode);
};




#endif
