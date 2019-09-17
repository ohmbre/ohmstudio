#include <algorithm>
#include <cmath>
#include <memory>
#include <cmath>
#include <QtConcurrent/QtConcurrent>

#include "common.hpp"

constexpr auto PI = 3.14159265358979323846;
constexpr auto TAU = 6.283185307179586;

#define V double
#define _comma_ ,
#define PADRE QGuiApplication::instance()

static QList<const QMetaObject *> metaFns;
const QMetaObject *addMetaFn(const QMetaObject *fn) {
    metaFns.append(fn);
    return fn;
}
#define META_REGISTER(type) \
    const static QMetaObject* type##Meta = addMetaFn(&type::staticMetaObject);

/*-------------------------------------------*/

class Ohm {
public:
    virtual ~Ohm() {}
    virtual V get() = 0;
    Q_INVOKABLE bool isOhm() {return true;}
    qint16 v16b() {
        V v = this->get() * 3276.7;
        v += 0.5 - (v < 0);
        v = qBound(-32768.0, v, 32767.0);
        return static_cast<qint16>(v);
    }
    virtual QString repr() = 0;
};
Q_DECLARE_INTERFACE(Ohm, "org.ohm.studio.Ohm")


/*-------------------------------------------*/

static quint64 t = 0;

class Time : public QObject, public Ohm {
    Q_OBJECT
    Q_INTERFACES(Ohm)
    Q_CLASSINFO("ref","time")
public:
    Q_INVOKABLE Time() : QObject(PADRE) {
        this->setObjectName("Ohm");
    }
    V get() {
        return static_cast<double>(t);
    }
    Q_INVOKABLE QString repr() {
        return QString("<time: %1>").arg(t);
    }
};
META_REGISTER(Time)

/*-------------------------------------------*/

static V inSampleL = 0;
static V inSampleR = 0;

class Capture: public QObject, public Ohm {
    Q_OBJECT
    Q_INTERFACES(Ohm)
    Q_CLASSINFO("ref","capture")
public:
    Q_INVOKABLE Capture(qint64 stream) : QObject(PADRE) {
        if (stream == 0) val = &inSampleL;
        else val = &inSampleR;
    }
    Q_INVOKABLE V get() { return *val; }
    Q_INVOKABLE QString repr() {
        return QString("<Capture: %1>").arg(val == &inSampleL ? 0 : 1);
    }
protected:
    V *val;
};
META_REGISTER(Capture)

/*-------------------------------------------*/

class Val : public QObject, public Ohm {
    Q_OBJECT
    Q_INTERFACES(Ohm)
    Q_CLASSINFO("ref", "val")
public:
    Q_INVOKABLE Val(V _val) : QObject(PADRE), val(_val) {
        this->setObjectName("Ohm");
    }
    Q_INVOKABLE V get() { return val; }
    void set(V _val) { val = _val; }
    Q_INVOKABLE QString repr() {
        return QString("<val: %1>").arg(val);
    }
protected:
    V val;
};
META_REGISTER(Val)


/*-------------------------------------------*/


class Func : public QObject, public Ohm {
    Q_INTERFACES(Ohm)
    virtual V next() = 0;
    V lastT;
    V lastEval;
public:
    Func() : QObject(PADRE), lastT(-1) {
        this->setObjectName("Ohm");
    }
    Q_INVOKABLE V get() {
        V curT = t;
        if (curT - lastT < 0.0001) return lastEval;
        lastEval = this->next();
        lastT = curT;
        return lastEval;
    }
};

#define DO_0(fn,rest...)
#define DO_1(fn,arg,rest...) fn(arg)
#define DO_2(fn,arg,rest...) fn(arg), DO_1(fn,rest)
#define DO_3(fn,arg,rest...) fn(arg), DO_2(fn,rest)
#define DO_4(fn,arg,rest...) fn(arg), DO_3(fn,rest)
#define DO_5(fn,arg,rest...) fn(arg), DO_4(fn,rest)
#define DO_6(fn,arg,rest...) fn(arg), DO_5(fn,rest)
#define DO_7(fn,arg,rest...) fn(arg), DO_6(fn,rest)
#define DO_N(n,fn,rest...) DO_##n(fn,rest)

#define NOP(arg) arg
#define VARG(arg) V arg
#define STAR(arg) * arg
#define ARGLIST a,b,c,d,e
#define QDEC(arg) QObject *_##arg
#define QARG(a) a(qobject_cast<Ohm*>(_##a))
#define ODEC(arg) Ohm *arg;
#define OGET(arg) arg->get()

/*-------------------------------------------*/

class List : public Func {
private:
    Q_OBJECT
    Q_INTERFACES(Ohm)
    Q_CLASSINFO("ref", "list")
public:
    QList<Ohm*> data;
    Ohm *index;
    int length;

    Q_INVOKABLE List(QJSValue _data, QObject *_index) : Func() {
        index = qobject_cast<Ohm*>(_index);
        if (_data.isArray()) {
            length = static_cast<int>(_data.property("length").toInt());
            for (int i = 0; i < length; i++)
                data << qobject_cast<Ohm*>(_data.property(static_cast<quint32>(i)).toQObject());
        } else
            length = 0;
    }

    Q_INVOKABLE V next() {
        if (length == 0) return 0;
        int idx = qRound(index->get());
        return data[idx % length]->get();
    }

    Q_INVOKABLE QString repr() {
        QStringList datareps;
        for (int i = 0; i < length; i++)
            datareps << data[i]->repr();
        QString datarep = "[" + datareps.join(", ") + "]";
        return QString("<list data:%1 index:%2>").arg(datarep,index->repr());

    }
};
META_REGISTER(List)

/*-------------------------------------------*/

class CVList : public List {
private:
    Q_OBJECT
    Q_INTERFACES(Ohm)
    Q_CLASSINFO("ref", "cvlist")
public:
    Q_INVOKABLE CVList(QJSValue _data, QObject *_index) : List(_data, _index) {}

    Q_INVOKABLE V next() {
        if (length == 0) return 0;
        int idx = static_cast<int>(floor((10.0+index->get())/10.0 * length));
        return data[idx % length]->get();
    }

};
META_REGISTER(CVList)



/*-------------------------------------------*/

#define FUNCHEAD(type,ref) \
  class type: public Func { \
    private: \
      Q_OBJECT \
      Q_INTERFACES(Ohm) \
      Q_CLASSINFO("ref", #ref)

#define FUNCFOOT(type) }; META_REGISTER(type)

#define FUNC(type,ref,pub,priv) \
  FUNCHEAD(type,ref) \
    priv \
  public: \
    pub \
  FUNCFOOT(type)

#define REPMAC(rep) QString("%1: %2").arg(#rep, rep->repr())

#define GENFUNC(nargs,type,ref,setupdef,nextdef,args...) FUNC(type,ref, \
      Q_INVOKABLE type(DO_N(nargs,QDEC,args)) : Func() _comma_ DO_N(nargs,QARG,args) \
      setupdef \
      Q_INVOKABLE QString repr() { \
        return QString("<%1 %2>").arg(#ref, QStringList({ DO_N(nargs,REPMAC,args) }).join(", ")); \
      }, \
      Ohm DO_N(nargs,STAR,args); V next() nextdef)

#define OPFUNC(nargs,type,ref,op) \
    GENFUNC(nargs,type,ref,{},{ \
      return op(DO_N(nargs,OGET,ARGLIST)); \
    },DO_N(nargs,NOP,ARGLIST))

#define LAMBDA(nargs,expr) [](DO_N(nargs,VARG,ARGLIST)) -> V { return expr; }

OPFUNC(1, Abs, abs, fabs)
OPFUNC(1, Exp, exp, exp)
OPFUNC(1, Exp2, exp2, exp2)
OPFUNC(1, Log, log, log)
OPFUNC(1, Log10, log10, log10)
OPFUNC(1, Log2, log2, log2)
OPFUNC(1, Sin, sin, sin)
OPFUNC(1, Cos, cos, cos)
OPFUNC(1, Tan, tan, tan)
OPFUNC(1, Asin, asin, asin)
OPFUNC(1, Acos, acos, acos)
OPFUNC(1, Atan, atan, atan)
OPFUNC(1, Sinh, sinh, sinh)
OPFUNC(1, Cosh, cosh, cosh)
OPFUNC(1, Tanh, tanh, tanh)
OPFUNC(1, Floor, floor, floor)
OPFUNC(1, Trunc, trunc, trunc)
OPFUNC(1, Ceil, ceil, ceil)
OPFUNC(2, Mod, mod, fmod)
OPFUNC(2, Remainder, remainder, remainder)
OPFUNC(2, Pow, pow, pow)
OPFUNC(2, Max, max, fmax)
OPFUNC(2, Min, min, fmin)
OPFUNC(2, Fdim, dim, fdim)
OPFUNC(2, Hypot, hypot, hypot)
OPFUNC(2, Atan2, atan2, atan2)
OPFUNC(3, Fma, fma, fma)
OPFUNC(1, UnaryMinus, unaryMinus, LAMBDA(1,-a))
OPFUNC(2, Smaller, smaller, LAMBDA(2, a < b ? 1 : 0))
OPFUNC(2, SmallerEq, smallerEq, LAMBDA(2, a <= b ? 1 : 0))
OPFUNC(2, Larger, larger, LAMBDA(2, a > b ? 1 : 0))
OPFUNC(2, LargerEq, largerEq, LAMBDA(2, a >= b ? 1 : 0))
OPFUNC(2, Add, add, LAMBDA(2, a+b))
OPFUNC(2, Subtract, subtract, LAMBDA(2, a - b))
OPFUNC(2, Multiply, multiply, LAMBDA(2, a * b))
OPFUNC(2, Divide, divide, LAMBDA(2, a / b))
OPFUNC(3, Conditional, conditional, LAMBDA(3, fabs(a) > 1e-9 ? b : c))

GENFUNC(1, Sinusoid, sinusoid,
     { phase = 0; },
     {
        phase += freq->get();
        return sin(phase);
     }
     V phase;
     , freq)

GENFUNC(1, Sawtooth, sawtooth,
     { phase = 0; },
     {
        phase += freq->get();
        return fmod(this->phase, TAU) / PI - 1;
     }
     V phase;
     , freq)

GENFUNC(3, SawSin, sawsin,
     { phase = 0; },
     {
         phase += freq->get();
         return atan(sin(phase)/(cos(phase)+exp(decay->get()*timer->get())));
     }
     V phase;
     , freq, decay, timer)

GENFUNC(2, PWM, pwm,
     { phase = 0; },
     {
         phase += freq->get();
         return ((fmod(phase,TAU) / TAU) < duty->get()) ? 1 : -1;
     }
     V phase;
     , freq, duty)

GENFUNC(1, StopWatch, stopwatch,
     {
        timer = 1e100;
        hi = false;
     },
     {
        timer++;
        V trigv = trig->get();
        if (!hi && trigv >= 3) {
            hi = true;
            timer = 0;
        } else if (hi && trigv < 3)
            hi = false;
        return timer;
     }
     V timer; bool hi;
     , trig)

GENFUNC(2, Counter, counter,
     {
         count = 0;
         ingate = false;
     },
     {
         if (reset->get() >= 3) count = 0;
         V clklvl = clk->get();
         if (!ingate && clklvl >= 3) {
             ingate = true;
             count++;
         } else if (ingate && clklvl <= 1)
             ingate = false;
         return count;
     }
     V count;
     bool ingate;
    , clk, reset)

GENFUNC(3, ClkDiv, clkdiv,
     {
         count = 0;
         ingate = false;
     },
     {
        V clklvl = clk->get();
        quint64 divnow = static_cast<quint64>(div->get());
        quint64 shiftnow = static_cast<quint64>(shift->get());
        if (!ingate && clklvl >= 3) {
            ingate = true;
            count++;
            if ((count - shiftnow) % divnow == 0)
                outgate = true;
        } else if (ingate && clklvl <= 1) {
            ingate = false;
            if (outgate) outgate = false;
        }
        return outgate ? 10 : 0;
     }
     quint64 count;
     bool ingate;
     bool outgate;
     , clk, div, shift)


GENFUNC(4, Random, random,
        {
            count = 0;
            state = 0;
        },
        {
            if (count == 0) state = static_cast<qint64>(qRound(seed->get()));
            if (state < 1) state = 1;
            qint64 imodulus = static_cast<qint64>(qRound(modulus->get()));
            if (imodulus <= 0) imodulus = 2147483647L;
            count = (count + 1) % imodulus;
            V l = lo->get();
            V h = hi->get();
            V ret = state / 2147483646.0 * (h-l)+l;
            state = (48271 * state) % 2147483647L;
            return ret;
        }
        qint64 state;
        qint64 count;
        , seed, lo, hi, modulus)

GENFUNC(3, Slew, slew,
        {
            val = 0;
        },
        {
            V sigval = signal->get();
            if (sigval > val)
                val += 1/risedamp->get() * (sigval - val);
            else
                val -= 1/falldamp->get() * (val - sigval);
            return val;
        }
        V val;
        , signal, risedamp, falldamp)


GENFUNC(2, SampleHold, samplehold,
        {
            sample = 0;
            hi = false;
        },
        {
            V trigv = trig->get();
            if (hi && trigv < 3) hi = false;
            else if (!hi && trigv >= 3) {
                hi = true;
                sample = signal->get();
            }
            return sample;
        }
        V sample; bool hi;
        , signal, trig)


GENFUNC(7, BiQuad, biquad,
        { x1 = 0; x2 = 0; y1 = 0; y2 = 0;},
        {
            V x = signal->get();
            V a0t = a0->get();
            V y = x/a0t*b0->get() + x1/a0t*b1->get() + x2/a0t*b2->get() - y1/a0t*a1->get() - y2/a0t*a2->get();
            x2 = x1;
            x1 = x;
            y2 = y1;
            y1 = y;
            return y;
        }
        V x1;
        V x2;
        V y1;
        V y2;
        , signal, a0, a1, a2, b0, b1, b2)


GENFUNC(3, HiPass, hipass,
        { x1 = 0; x2 = 0; y1 = 0; y2 = 0;},
        {
            V f = freq->get();
            V q = Q->get();
            V x = signal->get();
            V cs = cos(f);
            V sn = sin(f);
            V alpha = sn*sinh(0.34657359027997264*f/(q*sn));
            V cs1 = 1+cs;
            V b02 = cs1/2;
            V y = (b02*x - cs1*x1 + b02*x2 + 2*cs*y1 + (alpha-1)*y2)/(1+alpha);
            x2 = x1;
            x1 = x;
            y2 = y1;
            y1 = y;
            return y;
        }
        V x1;
        V x2;
        V y1;
        V y2;
        , signal, freq, Q)

GENFUNC(3, LoPass, lopass,
        { x1 = 0; x2 = 0; y1 = 0; y2 = 0;},
        {
            V f = freq->get();
            V q = Q->get();
            V x = signal->get();
            V cs = cos(f);
            V sn = sin(f);
            V alpha = sn*sinh(0.34657359027997264*f/(q*sn));
            V b1 = 1-cs;
            V b02 = b1/2;
            V y = (b02*x + b1*x1 + b02*x2 + 2*cs*y1 + (alpha-1)*y2)/(1+alpha);
            x2 = x1;
            x1 = x;
            y2 = y1;
            y1 = y;
            return y;
        }
        V x1;
        V x2;
        V y1;
        V y2;
        , signal, freq, Q)

GENFUNC(3, BandPass, bandpass,
        { x1 = 0; x2 = 0; y1 = 0; y2 = 0;},
        {
            V f = freq->get();
            V q = Q->get();
            V x = signal->get();
            V sn = sin(f);
            V alpha = sn*sinh(0.34657359027997264*f/(q*sn));
            V y = (alpha*(x - x2 + y2) + 2*cos(f)*y1 - y2)/(1+alpha);
            x2 = x1;
            x1 = x;
            y2 = y1;
            y1 = y;
            return y;
        }
        V x1;
        V x2;
        V y1;
        V y2;
        , signal, freq, Q)

GENFUNC(3, NotchFilt, notchfilter,
        { x1 = 0; x2 = 0; y1 = 0; y2 = 0;},
        {
            V f = freq->get();
            V q = Q->get();
            V x = signal->get();
            V sn = sin(f);
            V alpha = sn*sinh(0.34657359027997264*f/(q*sn));
            V m2cs = -2*cos(f);
            V y = (x + m2cs*x1 + x2 - m2cs*y1 + (alpha-1)*y2)/(1+alpha);
            x2 = x1;
            x1 = x;
            y2 = y1;
            y1 = y;
            return y;
        }
        V x1;
        V x2;
        V y1;
        V y2;
        , signal, freq, Q)

GENFUNC(4, PeakFilter, peakfilter,
        { x1 = 0; x2 = 0; y1 = 0; y2 = 0;},
        {
            V f = freq->get();
            V q = Q->get();
            V x = signal->get();
            V sn = sin(f);
            V g = gain->get();
            V alpha = sn*sinh(0.34657359027997264*f/(q*sn));
            V adivg = alpha/g;
            V ag = alpha*g;
            V b1 = -2*cos(f);
            V y = ((1+ag)*x + b1*(x1-y1) + (1-ag)*x2 - (1-adivg)*y2)/(1+adivg);
            x2 = x1;
            x1 = x;
            y2 = y1;
            y1 = y;
            return y;
        }
        V x1;
        V x2;
        V y1;
        V y2;
        , signal, freq, Q, gain)



class Backend : public QObject {
    Q_OBJECT
    QQmlApplicationEngine *engine;
    QHash<long, Val*> controls;
    //QHash<long, QVector<V>> quantrolMaps;
    QHash<QString, Ohm *> streams;
public:
    QScopedPointer<QByteArray> scopebuf;
    QByteArray *scopeOut;
    QByteArray scopeBytes;
    QJSValue qscope;
    int scopePos;
    int scopeLen;
    QMap<QString, QJSValue> refMap;
    short outsamples[SAMPLES_PER_PERIOD];
    short insamples[SAMPLES_PER_PERIOD];

    Backend(QQmlApplicationEngine *_engine) : QObject(PADRE), engine(_engine), scopeOut(nullptr),
        scopeBytes(512,0), qscope(QJSValue::NullValue), scopePos(0), scopeLen(0) {
        connect(this, &Backend::scopeDataReady, this, &Backend::scopeFireCallback, Qt::QueuedConnection);
    }

    Q_INVOKABLE void concurrently(QJSValue fn) {
        if (!fn.isCallable()) return;
        QtConcurrent::run(fn, &QJSValue::call, QJSValueList());
    }

    Q_INVOKABLE void setStream(QString key, QObject *_s) {
        Ohm *s = qobject_cast<Ohm*>(_s);
        streams[key] = s;
    }

    Q_INVOKABLE void enableScope(QJSValue _qscope) {
        qscope = _qscope;
    }

    Q_INVOKABLE void disableScope() {
        qscope = QJSValue::NullValue;
    }

    /*Q_INVOKABLE void setQuantrolMap(long id, QJSValueList choices) {
        QVector<V> map = quantrolMaps[id];
        map.resize(choices.count());
        int i = 0;
        QJSValue choice;
        foreach (choice, choices)
            map[i++] = choice.toNumber();
    }

    Q_INVOKABLE void setQuantrol(long id, int choice) {
        QVector<V> map = quantrolMaps[id];
        if (!map.count()) {
            qWarning() << "Error: no choices set on qantroller"  << id;
            return;
        }
        setControl(id, map[choice % map.count()]);
    }*/

    Q_INVOKABLE void setControl(long id, V val) {
        Val *control = controls[id];
        if (control) control->set(val);
        else controls[id] = new Val(val);
    }

    Q_INVOKABLE Val* getControl(long id) {
        Val *control = controls[id];
        if (control) return control;
        controls[id] = new Val(0);
        return controls[id];
    }

    Q_INVOKABLE QJSValue link(QString ref) {
        QJSValue symbol = refMap[ref];
        return symbol;
    }

    void ioloop(QIODevice *out, QIODevice *in) {
        char *bytesamples;
        long long taken;

        if (in != nullptr) {
            bytesamples = reinterpret_cast<char*>(insamples);
            taken = in->read(bytesamples, BYTES_PER_PERIOD);
            while (taken < BYTES_PER_PERIOD) {
                QEventLoop loop;
                connect(in, &QIODevice::readyRead, &loop, &QEventLoop::quit);
                loop.exec();
                taken += in->read(bytesamples + taken, BYTES_PER_PERIOD - taken);
            }
        }

        Ohm *outL = streams["outL"];
        Ohm *outR = streams["outR"];

        Ohm *scope = streams["scopeSignal"];
        Ohm *scopeTrig = streams["scopeTrig"];
        Ohm *scopeVtrig = streams["scopeVtrig"];
        Ohm *scopeWin = streams["scopeWin"];
        V strig = 0;
        bool scopeEnabled = !qscope.isNull();
        if (scopeEnabled && scopeVtrig)
            strig = scopeVtrig->get();
        short *scopeData;

        int samplepos = 0;
        while (samplepos < SAMPLES_PER_PERIOD) {
            inSampleL = insamples[samplepos];
            inSampleR = insamples[samplepos+1];
            outsamples[samplepos] = outL ? outL->v16b() : 0;
            outsamples[samplepos+1] = outR ? outR->v16b() : 0;
            samplepos += 2;
            if (scopeEnabled) {
                if (scopePos == scopeLen && scopeOut == nullptr && !scopebuf.isNull()) {
                    scopeOut = scopebuf.take();
                    emit scopeDataReady();
                } else if (scopePos < scopeLen) {
                    scopeData = reinterpret_cast<short *>(scopebuf.data()->data());
                    scopeData[scopePos++] = scope ? scope->v16b() : 0;
                } else if (scopebuf.isNull() && scopeTrig && scopeTrig->get() > strig) {
                    scopePos = 0;
                    scopeLen = scopeWin ? static_cast<int>(scopeWin->get()) : 0;
                    scopebuf.reset(new QByteArray(scopeLen*2, 0));
                }
            }
            t++;
        }

        bytesamples = reinterpret_cast<char*>(outsamples);
        taken = 0;
        while (taken < BYTES_PER_PERIOD) {
            taken += out->write(bytesamples + taken, BYTES_PER_PERIOD-taken);
            if (taken != BYTES_PER_PERIOD)
                QThread::msleep(7);
        }


    }

signals:
    void scopeDataReady();

public slots:
    void scopeFireCallback() {
        QJSValue callback = qscope.property("dataCallback");
        short *data = reinterpret_cast<short*>(scopeOut->data());
        double avg = 0;
        int bufpos = 0, buflen = scopeBytes.length(), datapos = 0, n = scopeOut->length()/2, scale = n / buflen;
        if (scale == 0) scale = 1;
        while (datapos < n) {
            avg += data[datapos++];
            if (datapos % scale == 0 && (datapos == n || ((datapos + scale) <= n)) && bufpos < buflen) {
                scopeBytes[bufpos++] = static_cast<char>(qBound(-128.0, round(avg/scale/256), 127.0));
                avg = 0;
            }
        }
        if (datapos % scale != 0)
            scopeBytes[bufpos] = static_cast<char>(qBound(-128.0, round(avg/(scale+(datapos % scale))/256.0), 127.0));
        if (callback.isCallable())
            callback.callWithInstance(qscope,QJSValueList() << engine->toScriptValue<QByteArray>(scopeBytes));
        delete scopeOut;
        scopeOut = nullptr;
    }

};

/*-------------------------------------------*/

static Backend *backend;

void initBackend(QQmlApplicationEngine *engine) {

    backend = new Backend(engine);

    QJSValue g = engine->globalObject();
    QListIterator<const QMetaObject *> metaIter(metaFns);
    while (metaIter.hasNext()) {
        const QMetaObject *meta = metaIter.next();
        g.setProperty(meta->className(), engine->newQMetaObject(meta));
        for (int i = 0; i < meta->classInfoCount(); i++) {
            QMetaClassInfo info = meta->classInfo(i+meta->classInfoOffset());
            if (info.name() && !strcmp(info.name(),"ref")) {
                backend->refMap[info.value()] = engine->newQMetaObject(meta);
            }
        }
    }
    g.setProperty("Backend",engine->newQObject(backend));
    qRegisterMetaType<Val*>("Val*");
    qRegisterMetaType<Val*>("List*");

}



void ioloop(QIODevice *out, QIODevice *in) {
    backend->ioloop(out, in);
}

#include "external/exprtk.hpp"

void test() {

    SymbolTable symtable;
      symtable.add_constant("pi", PI);
      symtable.add_constant("hz", 2*PI/48000);

}


#include "backend.moc"


