#include "common.hpp"
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
