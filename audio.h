#pragma once

#include "external/miniaudio.h"

#include "conductor.h"
#include "func.h"
#include "sink.h"



class Sink;

class Audio : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString outName READ outName WRITE setOutName NOTIFY changed)
    Q_PROPERTY(QString inName READ inName WRITE setInName NOTIFY changed)
    Q_PROPERTY(unsigned int outChanCount READ outChanCount NOTIFY changed)
    Q_PROPERTY(unsigned int inChanCount READ inChanCount NOTIFY changed)
    Q_PROPERTY(unsigned int sampleRate READ sampleRate WRITE setSampleRate NOTIFY changed)
public:
    Audio();
    ~Audio();
    
    Q_INVOKABLE QStringList availableDevs(bool output);
    Q_INVOKABLE void setOutChannel(int i, QObject *function);
    Q_INVOKABLE QFunc* getInChannel(int i);   
    Q_INVOKABLE QString outName();
    Q_INVOKABLE QString inName();
    Q_INVOKABLE void setOutName(QString name);
    Q_INVOKABLE void setInName(QString name);
    Q_INVOKABLE unsigned int outChanCount();
    Q_INVOKABLE unsigned int inChanCount();
    Q_INVOKABLE unsigned int sampleRate();
    Q_INVOKABLE void setSampleRate(unsigned int sampleRate);
    Q_INVOKABLE unsigned int period();
    Q_INVOKABLE void addSink(Sink *sink);
    Q_INVOKABLE void removeSink(Sink *sink);    
    Q_INVOKABLE void pause();
    Q_INVOKABLE void resume();
    
    void reset();
    
signals:
    void changed();
    
private:    
    bool initialized;
    QList<Func*> outChannels;
    QList<MutableFunc*> inChannels;
    ma_context ctx;
    ma_device dev;
    double sinkBuf[4*PERIOD*sizeof(double)];
    QList<Sink*> sinks;
    
    ma_device_id *getDevId(QString name, bool output);
};




