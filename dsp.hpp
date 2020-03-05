#include "conductor.hpp"
#include "sink.hpp"

#define FTDIM 4096

class Fourier : public QObject, public Sink {
    Q_OBJECT
public:
    Q_INVOKABLE Fourier();
    void flush() override;
    Q_INVOKABLE qint64 channelCount() { return nchan(); }
    Q_INVOKABLE void setChannel(int i, QObject *function) { sinkSetChannel(i, function); }
    Q_INVOKABLE QList<double> getBins();

private:
    V data[FTDIM];
    QQueue<V> dataBuf;
};
