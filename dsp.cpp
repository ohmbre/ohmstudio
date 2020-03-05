#include "dsp.hpp"


Q_INVOKABLE Fourier::Fourier() : QObject(QGuiApplication::instance()), Sink(1), data() {
    maestro.registerSink(this);
}


void Fourier::flush() {
    for (long i = 0; i < maestro.period; i++)
        dataBuf.enqueue(buf[i] / 32768.0);
    while (dataBuf.size() > FTDIM) dataBuf.dequeue();
}

Q_INVOKABLE QList<double> Fourier::getBins() {

    long i,j;
    QList<double> bins;

    if (dataBuf.size() < FTDIM) return bins;
    for (i = 0; i < FTDIM; i++)
        data[i] = dataBuf.dequeue();

    for (i = 0; i < FTDIM; i++) {
        V acc = 0;
        for (j = 0; j < FTDIM; j++) {
            V arg = 2 * M_PI * i * j / FTDIM;
            acc += data[j] * (cos(arg) + sin(arg));
        }
        bins.append(acc / FTDIM);
    }

    return bins;
}


