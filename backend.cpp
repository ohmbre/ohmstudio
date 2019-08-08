#include <algorithm>
#include <cmath>
#include <memory>
#include <QObject>
#include <QQmlContext>
#include <QQmlEngine>
#include <QJSValue>
#include <QVariant>
#include <cmath>
#include <QJSEngine>
#include <QQmlApplicationEngine>
#include <QJSValue>
#include <QDebug>
#include <QReadWriteLock>
#include <QMutex>
#include <QGuiApplication>

#define PI 3.14159265358979323846
#define TAU 6.283185307179586

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
};
Q_DECLARE_INTERFACE(Ohm, "org.ohm.studio.Ohm")


/*-------------------------------------------*/

static quint64 t = 0;

class Time : public QObject, public Ohm {
    Q_OBJECT
    Q_INTERFACES(Ohm)
    Q_CLASSINFO("ref","time")
public:
    Q_INVOKABLE Time() : QObject(PADRE) {}
    V get() {
        return static_cast<double>(t);
    }
};
META_REGISTER(Time)

/*-------------------------------------------*/

class Val : public QObject, public Ohm {
    Q_OBJECT
    Q_INTERFACES(Ohm)
    Q_CLASSINFO("ref", "val")
public:
    Q_INVOKABLE Val(V _val) : QObject(PADRE), val(_val) {}
    V get() { return val; }
    void set(V _val) { val = _val; }
protected:
    V val;
};
META_REGISTER(Val)


/*-------------------------------------------*/

class Backend : public QObject {
    Q_OBJECT
    QQmlApplicationEngine *engine;
    QHash<long, Val*> controls;
    QHash<QString, Ohm *> streams;
public:
    QScopedPointer<QByteArray> scopebuf;
    QByteArray *scopeOut;
    QByteArray scopeBytes;
    QJSValue qscope;
    int scopePos;
    int scopeLen;

    QMap<QString, QJSValue> refMap;

    Backend(QQmlApplicationEngine *_engine) : QObject(PADRE), engine(_engine), scopeOut(nullptr),
        scopeBytes(512,0), qscope(QJSValue::NullValue), scopePos(0), scopeLen(0) {
        connect(this, &Backend::scopeDataReady, this, &Backend::scopeFireCallback, Qt::QueuedConnection);
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

    void fillBuffer(short *buf, qint64 nframes) {
        Ohm *outL = streams["outL"];
        Ohm *outR = streams["outR"];

        Ohm *scope = streams["scope"];
        Ohm *scopeTrig = streams["scopeTrig"];
        Ohm *scopeVtrig = streams["scopeVtrig"];
        Ohm *scopeWin = streams["scopeWin"];
        V strig = 0;
        bool scopeEnabled = !qscope.isNull();
        if (scopeEnabled && scopeVtrig)
            strig = scopeVtrig->get();
        short *end = buf + 2*nframes;
        short *scopeData;

        while (buf < end) {
            *buf++ = outL ? outL->v16b() : 0;
            *buf++ = outR ? outR->v16b() : 0;
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


class Func : public QObject, public Ohm {
    Q_INTERFACES(Ohm)
    virtual V next() = 0;
    V lastT;
    V lastEval;
public:
    Func() : QObject(PADRE), lastT(-1) {
        this->setObjectName("Ohm");
    }
    V get() {
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
#define DO_N(n,fn,rest...) DO_##n(fn,rest)

#define NOP(arg) arg
#define VARG(arg) V arg
#define STAR(arg) * arg
#define ARGLIST a,b,c,d,e
#define QDEC(arg) QObject *_##arg
#define QARG(a) a(qobject_cast<Ohm*>(_##a))
#define ODEC(arg) Ohm *arg;
#define OGET(arg) arg->get()

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

#define GENFUNC(nargs,type,ref,setupdef,nextdef,args...) FUNC(type,ref, \
      Q_INVOKABLE type(DO_N(nargs,QDEC,args)) : Func() _comma_ DO_N(nargs,QARG,args) setupdef, \
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
OPFUNC(2, Mod, mod, fmod)
OPFUNC(2, Pow, pow, pow)
OPFUNC(2, Max, max, fmax)
OPFUNC(2, Min, max, fmin)
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



GENFUNC(3, ClkDiv, clkdiv,
     {
         count = 0;
         ingate = 0;
     },
     {
        V clklvl = clk->get();
        if (!ingate && clklvl >= 3) {
            ingate = true;
            count++;
        } else if (ingate && clklvl <= 1) {
            ingate = false;
            if (fmod(count - shift->get(), div->get()) == 0)
                return clklvl;
            return 0;
        }
        return 0;
     }
     V count;
     bool ingate;
     , clk, div, shift)


GENFUNC(1, Noise, noise,
        {
            state = 666;
        },
        {
            state = static_cast<quint64>(coef->get()) * state % 4294967291UL;
            return state / 2147483645.0 - 1.0;
        }
        quint64 state;
        , coef)

GENFUNC(3, Slew, slew,
        {
            val = 0;
        },
        {
            V sigval = signal->get();
            if (sigval > val)
                val += risedamp->get()/1000 * (sigval - val);
            else
                val -= falldamp->get()/1000 * (val - sigval);
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


/*

class sequence extends ohm {
    constructor(clock, values) {
        super()
            this.clock = clock
              this.values = values
              this.lastvalues = this.values[Symbol.toPrimitive]()
                  if (this.lastvalues === undefined)
                      throw new Error('could not get primitive from: '+values)
                          this.position = 0
              this.gate = false
    }
    [Symbol.toPrimitive]() {
        const clklvl = +this.clock
                        if (!this.gate && clklvl >= 3) {
            this.lastvalues = this.values[Symbol.toPrimitive]()
                                  this.gate = true
                  this.position = (this.position + 1) % this.lastvalues.length
        } else if (this.gate && clklvl <= 1)
            this.gate = false
              return this.lastvalues[this.position]
    }
}
*/

/*

class randsample extends ohm {
    constructor(pool, nsamples, seed) {
        super()
            this.pool = pool
          this.lastnsamples = 0
          this.nsamples = nsamples
          this.lastseed = 279470274
          this.seed = (typeof seed == 'undefined') ? Math.floor(Math.random() * 279470273) : seed
                                                                                 this.val = undefined
    }
        [Symbol.toPrimitive]() {
        let intseed = Math.round(this.seed)
                          let intnsamples = Math.round(this.nsamples)
                  if (intseed == this.lastseed && intnsamples == this.lastnsamples
                                                                    && this.val !== undefined) return this.val
              this.lastseed = intseed
              this.lastnsamples = intnsamples
            const val = []
            while (val.length < intnsamples) {
            val.push(this.pool[intseed % this.pool.length])
                intseed = (intseed * 279470273) % 4294967291
        }
        return this.val = val
    }
}




class ramps extends ohm {
    constructor(trig, initval, ...args) {
        super()
            this.trig = trig
          this.gate = false
          this.initval = initval
          this.timer = 0
          this.ramps = []
          this.args = [...args]
          this.val = initval
          this.running = false
    }
        [Symbol.toPrimitive]() {
        const siglvl = +this.trig
                        if (!this.gate && siglvl >= 3) {
            this.gate = this.running = true
                                       this.timer = 0
                  this.vstart = this.val
                  this.rampsleft = [...this.args]
                const ramplist = this.rampsleft.splice(0, 3)
                      this.target = ramplist[0]; this.len = ramplist[1]; this.shape = ramplist[2]
        } else if (this.gate && siglvl <= 1)
            this.gate = false
              if (!this.running) return this.val
              this.timer++
              let len = +this.len
               if (this.timer > len) {
            if (!this.rampsleft.length) {
                this.running = false
                               return this.val
            }
            const ramplist = this.rampsleft.splice(0, 3)
                                 this.target = ramplist[0]; this.len = ramplist[1]; this.shape = ramplist[2]
                len = +this.len
                   this.vstart = this.val
                  this.timer = 1
        }
        const target = +this.target, shape = +this.shape
                                              if (len == 0) return this.val = target
                                       return this.val = target + (this.vstart - target) * (1 - this.timer / len) ** shape
    }
}


*/


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
            if (!strcmp(info.name(),"ref")) {
                backend->refMap[info.value()] = engine->newQMetaObject(meta);
            }
        }
    }
    g.setProperty("Backend",engine->newQObject(backend));
    qRegisterMetaType<Val*>("Val*");
}




void fillBuffer(short *buf, qint64 nframes) {
    backend->fillBuffer(buf, nframes);
}

#include "backend.moc"


