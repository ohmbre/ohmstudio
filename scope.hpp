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
    void paint(QPainter *painter) override;
    void flush() override;
    Q_INVOKABLE qint64 channelCount() { return nchan(); }
    Q_INVOKABLE void setChannel(int i, QObject *function) { sinkSetChannel(i, function); }
private:
    double m_timeWindow;
    V m_trig;

    QMutex dataLock;
    QQueue<V> dataBuf1;
    QQueue<V> dataBuf2;
};


#define FFTSAMPLES 4096
#define FFTPOW 1.05

class FFTScope : public QQuickPaintedItem, public Sink {
    Q_OBJECT
public:
    FFTScope(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;
    void flush() override;
    Q_INVOKABLE qint64 channelCount() { return nchan(); }
    Q_INVOKABLE void setChannel(int i, QObject *function) { sinkSetChannel(i, function); }
    double binToFreq(double i);
    double freqToBin(double f);
    double freqToX(double f, double width);
private:
    V data[FFTSAMPLES];
    V bins[FFTSAMPLES];
    QVector<QPointF> polyline;
    V constants[FFTSAMPLES][FFTSAMPLES];
    QMutex dataLock;
    QQueue<V> dataBuf;
};


