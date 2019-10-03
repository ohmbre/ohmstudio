#include "scope.hpp"
#include "conductor.hpp"

Scope::Scope(QQuickItem *parent) : QQuickPaintedItem(parent), Sink(2), trigpos(-1), trackpos(-1), ntracked(0) {
    maestro.registerSink(this);
    lastVal = 32768;
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

    pen.setColor(QColor(150,150,150));
    pen.setWidthF(0.5);
    pen.setStyle(Qt::DotLine);
    painter->setPen(pen);
    painter->drawLine(.25*w,     0, .25*w,     h);
    painter->drawLine(.75*w,     0, .75*w,     h);
    painter->drawLine(    0, .25*h,     w, .25*h);
    painter->drawLine(    0, .75*h,     w, .75*h);

    pen.setWidthF(0.7);
    pen.setColor(QColor(100,100,100));
    pen.setStyle(Qt::DotLine);
    painter->setPen(pen);
    painter->drawLine(    0,  .5*h,     w,  .5*h);
    painter->drawLine( .5*w,     0,  .5*w,     h);

    pen.setColor(QColor(0,0,0));
    painter->setPen(pen);
    painter->setFont(QFont("Asap SemiBold", 4));
    painter->drawText(QRect(0,0,13,8), Qt::AlignHCenter | Qt::AlignVCenter, "10V" );
    painter->drawText(QRect(0,h-8,13,8), Qt::AlignHCenter | Qt::AlignVCenter, "-10V" );

    long long nsamples = round(m_timeWindow*48);

    double timeinc = w/nsamples;

    QVector<QPointF> polyline(nsamples);

    long long start,end;

    if (trigpos != -1) {
        start = trigpos - nsamples/2*2;
        end = trigpos + (nsamples+1)/2*2;
        pen.setColor(QColor(0,128,7));
        painter->setPen(pen);
        painter->drawText(QRect(w/2-20,h-10,40,10), Qt::AlignHCenter | Qt::AlignVCenter, "trig (ch1) lock");
    } else {
        start = bf - nsamples*2;
        end = bf;
        pen.setColor(QColor(128,7,0));
        painter->setPen(pen);
        painter->drawText(QRect(w/2-20,h-10,40,10), Qt::AlignHCenter | Qt::AlignVCenter, "trig (ch1) no lock");
    }

    double xpos;
    long long i,idx;
    pen.setWidthF(1);
    pen.setStyle(Qt::SolidLine);

    if (channels[0]) {
        for (i = 0, idx = start, xpos = 0; idx < end; i++, idx += 2, xpos += timeinc)
            polyline[i] = QPointF(xpos,h/2*(1-ringbuf[((idx < 0) ? (idx+RINGBUFLEN) : idx) % RINGBUFLEN]/32768.0));
        pen.setColor(QColor(255,64,16,200));
        painter->setPen(pen);
        painter->drawPolyline(polyline);
    }
    if (channels[1]) {
        for (i = 0, idx = start+1, xpos = 0; idx < end; i++, idx += 2, xpos += timeinc)
            polyline[i] = QPointF(xpos,h/2*(1-ringbuf[((idx < 0) ? (idx+RINGBUFLEN) : idx) % RINGBUFLEN]/32768.0));
        pen.setColor(QColor(16,64,255,200));
        painter->setPen(pen);
        painter->drawPolyline(polyline);
    }

}

int Scope::writeData(Sample *buf, long long count) {
    long long nsamples = round(m_timeWindow*48);
    long long needed = (nsamples+1)/2;

    if (bf-trigpos > RINGBUFLEN) trigpos = -1;

    for (int i = 0; i < count; i += 2) {
        if (trackpos == -1) {
            if (lastVal < m_trig && buf[i] >= m_trig) {
                trackpos = bi + i;
                ntracked = 0;
            }
        } else {
            ntracked++;
            if (ntracked >= needed) {
                trigpos = trackpos;
                trackpos = -1;
                ntracked = 0;
            }
        }
        lastVal = buf[i];
    }
    return count;
}
