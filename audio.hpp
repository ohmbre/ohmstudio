
#ifndef INCLUDE_AUDIO_HPP
#define INCLUDE_AUDIO_HPP

#include "conductor.hpp"
#include "function.hpp"

void createAudioContext();
void destroyAudioContext();


class AudioIn : public QIODevice {
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

void decodeSamples(QString path, QList<double> *samples);

#endif
