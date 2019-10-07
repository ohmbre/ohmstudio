#include "conductor.hpp"
#include "sink.hpp"

class Scope : public QQuickPaintedItem, public Sink {
    Q_OBJECT
    Q_PROPERTY(double timeWindow READ timeWindow WRITE setTimeWindow)
    Q_PROPERTY(double trig READ trig WRITE setTrig)
public:
    Scope(QQuickItem *parent = nullptr);
    double timeWindow();
    void setTimeWindow(double timeWindow);
    double trig();
    void setTrig(double trig);
    void paint(QPainter *painter);
    int writeData(Sample *buf, long long count);
    Q_INVOKABLE qint64 channelCount() { return sinkChannelCount(); }
    Q_INVOKABLE void setChannel(int i, QObject *function) { sinkSetChannel(i, function); }
private:
    double m_timeWindow;
    double m_trig;
    double lastVal;
    long long trigpos;
    long long trackpos;
    long long ntracked;
};


#define FFTSAMPLES 2000
#define FFTPOW 1.05

class FFTScope : public QQuickPaintedItem, public Sink {
    Q_OBJECT
public:
    FFTScope(QQuickItem *parent = nullptr);
    void paint(QPainter *painter);
    int writeData(Sample *buf, long long count);
    Q_INVOKABLE qint64 channelCount() { return sinkChannelCount(); }
    Q_INVOKABLE void setChannel(int i, QObject *function) { sinkSetChannel(i, function); }
    double binToFreq(double i) { return 35*pow(2,i*log2(FRAMES_PER_SEC/2/35.0)/FFTSAMPLES); }
    double freqToBin(double f) { return log2(f/35)*FFTSAMPLES/log2(FRAMES_PER_SEC/2/35); }
    double freqToX(double f, double width) { return freqToBin(f)/FFTSAMPLES * width; }
private:
    V dataBuf[FFTSAMPLES];
    V fftBuf[FFTSAMPLES];
    long writePos;
};
