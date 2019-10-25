
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
    static QAudioFormat getFormat();
    Q_INVOKABLE static QStringList availableDevs();
    static QAudioDeviceInfo devInfo(const QString &name);
    QAudioOutput *dev;
    QIODevice *iodev;
};







#endif
