#include "conductor.hpp"

#define FTDIM 4096

class Fourier : public QObject {
    Q_OBJECT
public:
    Q_INVOKABLE Fourier();
    ~Fourier() {}
    void flush();
    Q_INVOKABLE qint64 channelCount() { return 0; }
    Q_INVOKABLE void setChannel(int , QObject *) { }
    Q_INVOKABLE QList<double> getBins();

private:
    V data[FTDIM];
    QQueue<V> dataBuf;
};
