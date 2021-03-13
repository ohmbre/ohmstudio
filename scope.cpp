#include "scope.hpp"

Scope::Scope(QQuickItem *parent) : QQuickPaintedItem(parent) {
    setTextureSize(QSize(241*5,113*5));
    setRenderTarget(QQuickPaintedItem::FramebufferObject);
}


double Scope::timeWindow() { return m_timeWindow; }
void Scope::setTimeWindow(double timeWindow) { m_timeWindow = timeWindow; }
double Scope::trig() { return m_trig/3276.7; }
void Scope::setTrig(double trig) { m_trig = trig*3276.7; }

void Scope::paint(QPainter *painter) {
    qreal w = width();
    qreal h = height();

    QPen pen;
    painter->setRenderHints(QPainter::Antialiasing, true);
    painter->setCompositionMode(QPainter::CompositionMode_SourceOver);
    pen.setColor(QColor(150,150,150));
    pen.setWidthF(0.5);
    pen.setStyle(Qt::DotLine);
    painter->setPen(pen);

    painter->drawLine(QLineF(.25*w,     0, .25*w,     h));
    painter->drawLine(QLineF(.75*w,     0, .75*w,     h));
    painter->drawLine(QLineF(    0, .25*h,     w, .25*h));
    painter->drawLine(QLineF(    0, .75*h,     w, .75*h));

    pen.setWidthF(0.7);
    pen.setColor(QColor(100,100,100));
    pen.setStyle(Qt::DotLine);
    painter->setPen(pen);
    painter->drawLine(QLineF(    0,  .5*h,     w,  .5*h));
    painter->drawLine(QLineF( .5*w,     0,  .5*w,     h));

    pen.setColor(QColor(0,0,0));
    painter->setPen(pen);
    painter->setFont(QFont("Asap SemiBold", 4));
    painter->drawText(QRect(0,0,13,8), Qt::AlignHCenter | Qt::AlignVCenter, "10V" );
    painter->drawText(QRectF(0,h-8,13,8), Qt::AlignHCenter | Qt::AlignVCenter, "-10V" );

    long nsamples = qRound(m_timeWindow*maestro.audioOut->sampleRate()/1000);

    //double timeinc = w/nsamples;

    QVector<QPointF> polyline(static_cast<int>(nsamples));


    /*if (trigpos != -1) {
        pen.setColor(QColor(0,128,7));
        painter->setPen(pen);
        painter->drawText(QRectF(w/2-20,h-10,40,10), Qt::AlignHCenter | Qt::AlignVCenter, "trig (ch1) lock");
    } else {
    */
    pen.setColor(QColor(128,7,0));
    painter->setPen(pen);
    painter->drawText(QRectF(w/2-20,h-10,40,10), Qt::AlignHCenter | Qt::AlignVCenter, "trig (ch1) no lock");


    //double xpos;
    //int i;
    pen.setWidthF(1);
    pen.setStyle(Qt::SolidLine);
    painter->setCompositionMode(QPainter::CompositionMode_DestinationOver);
    dataLock.lock();
    while (dataBuf1.size() > nsamples) dataBuf1.removeFirst();
    while (dataBuf2.size() > nsamples) dataBuf2.removeFirst();

    /*if (channels[0]) {
        long end = qMin(nsamples, (long)dataBuf1.size());
        for (i = 0, xpos = 0; i < end; i++, xpos += timeinc)
            polyline[i] = QPointF(xpos,h/2*(1-dataBuf1[i]));
        pen.setColor(QColor(211,81,42,200));
        painter->setPen(pen);
        painter->drawPolyline(polyline);
    }
    if (channels[1]) {
        long end = qMin(nsamples, (long)dataBuf1.size());
        for (i = 0, xpos = 0; i < end; i++, xpos += timeinc)
            polyline[i] = QPointF(xpos,h/2*(1-dataBuf2[i]));
        pen.setColor(QColor(0,176,186,200));
        painter->setPen(pen);
        painter->drawPolyline(polyline);
    }*/
    dataLock.unlock();

}

void Scope::flush() {

    dataLock.lock();
    for (unsigned int i = 0; i < PERIOD; i ++) {
        /*V ch1v = buf[2*i]/32768.0;
        V ch2v = buf[2*i]/32768.0;
        dataBuf1.enqueue(ch1v);
        dataBuf2.enqueue(ch2v);*/
    }
    dataLock.unlock();

}


FFTScope::FFTScope(QQuickItem *parent) : QQuickPaintedItem(parent), data(), polyline(FFTSAMPLES/2-1), dataLock() {
    for (long i = 0; i < FFTSAMPLES; i++)
        for (long j = 0; j < FFTSAMPLES; j++) {
            V arg = 2 * M_PI * i * j / FFTSAMPLES;
            constants[i][j] = cos(arg) + sin(arg);
        }
    setTextureSize(QSize(241*5,113*1.3*5));
    setRenderTarget(QQuickPaintedItem::FramebufferObject);
}



double FFTScope::binToFreq(double i) {
    return i*maestro.sym_s/FFTSAMPLES;
}
double FFTScope::freqToBin(double f) {
    return FFTSAMPLES * f / maestro.sym_s;
}
double FFTScope::freqToX(double f, double width){
    return log2(f / 35) / log2(maestro.sym_s / 2 / 35) * width;
}


void FFTScope::paint(QPainter *painter) {

    qreal w = width();
    qreal h = height();

    QPen pen;
    painter->setRenderHints(QPainter::Antialiasing, true);

    pen.setColor(QColor(175,175,175,128));
    pen.setWidthF(0.4);
    pen.setStyle(Qt::DotLine);
    painter->setPen(pen);
    painter->drawLine(    0, .25*h,     w, .25*h);
    painter->drawLine(    0,  .5*h,     w,  .5*h);
    painter->drawLine(    0, .75*h,     w, .75*h);

    pen.setWidthF(1);
    pen.setStyle(Qt::SolidLine);
    pen.setColor(QColor(255,64,16,200));
    painter->setPen(pen);


    /*if (channels[0]) {
        bool haveData = false;
        dataLock.lock();
        if (dataBuf.size() >= FFTSAMPLES) {
            while (dataBuf.size() > FFTSAMPLES) dataBuf.removeFirst();
            for (long i = 0; i < FFTSAMPLES; i++)
                data[i] = dataBuf.dequeue();
            for (long i = 0; i < FFTSAMPLES; i++) {
                V acc = 0;
                for (long j = 0; j < FFTSAMPLES; j++) {
                    //V arg = 2 * M_PI * i * j / FFTSAMPLES;
                    //acc += data[j] * (cos(arg) + sin(arg));
                    acc += data[j] * constants[i][j];
                }
                bins[i] = acc / FFTSAMPLES;
            }
            haveData = true;
        }
        dataLock.unlock();
        if (haveData) {
            for (long i = 1; i < FFTSAMPLES/2; i++)
                polyline[i-1] = QPointF(freqToX(binToFreq(i),w), h*(1-sqrt(2*(bins[i]*bins[i] + bins[FFTSAMPLES-i]*bins[FFTSAMPLES-i]))));
            painter->drawPolyline(polyline);
        }
    }*/

    pen.setStyle(Qt::DotLine);
    pen.setWidthF(0.4);
    painter->setPen(pen);
    painter->setFont(QFont("Asap SemiBold", 3));

    QHash<int,QString> lf = {
        {20,""},
        {30,""},
        {40,""},
        {50,""},
        {60,""},
        {70,""},
        {80,""},
        {90,""},
        {100,"100Hz"},
        {200,""},
        {300,""},
        {400,""},
        {500,""},
        {600,""},
        {700,""},
        {800,""},
        {900,""},
        {1000,"1kHz"},
        {2000,""},
        {3000,""},
        {4000,""},
        {5000,""},
        {6000,""},
        {7000,""},
        {8000,""},
        {9000,""},
        {10000,"10kHz"},
        {20000,""}
    };
    foreach(int f, lf.keys()) {
        double x = freqToX(f,w);
        if (lf[f] != "") {
            pen.setColor(QColor(0,0,0));
            painter->setPen(pen);
            painter->drawText(QRect(x-8,h-7,16,7), Qt::AlignHCenter | Qt::AlignVCenter, lf[f]);
            pen.setColor(QColor(64,64,64,128));
        } else
            pen.setColor(QColor(175,175,175,128));

        painter->setPen(pen);
        painter->drawLine(x, 2, x, h-1);
    }

}


void FFTScope::flush() {
    dataLock.lock();
    //for (unsigned int i = 0; i < maestro.period(); i++)
    //    dataBuf.enqueue(buf[i]/32768.0);
    dataLock.unlock();
}





