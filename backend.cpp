

#include <algorithm>
#include <cmath>

#include <QObject>
#include <QQmlContext>
#include <QQmlEngine>
#include <QJSValue>
#include <QVariant>
#include <cmath>
#include <QJSEngine>
#include <QQmlEngine>
#include <QJSValue>
#include <QDebug>
#include <QReadWriteLock>
#include <QMutex>
#include <QGuiApplication>

#define PI 3.14159265358979323846
#define TAU 6.283185307179586


typedef double(*unaryFn)(double);
static const QMap<QString, unaryFn> unaryFuncs {
    {"abs", &abs},
    {"exp", &exp},
    {"exp2", &exp2},
    {"log", &log},
    {"log10", &log10},
    {"log2", &log2},
    {"sin", &sin},
    {"cos", &cos},
    {"tan", &tan},
    {"asin", &asin},
    {"acos", &acos},
    {"atan", &atan},
    {"unaryMinus", [](double a) -> double { return -a; }}};

typedef double(*binaryFn)(double,double);
static const QMap<QString, binaryFn> binaryFuncs {
    {"mod", &fmod},
    {"pow", &pow},
    {"max", &fmax},
    {"min", &fmin},
    {"fdim", &fdim},
    {"hypot", &hypot},
    {"atan2", &atan2},
    {"smaller", [](double a, double b) -> double { return a < b ? 1 : 0; }},
    {"smallerEq", [](double a, double b) -> double { return a <= b ? 1 : 0; }},
    {"larger", [](double a, double b) -> double { return a > b ? 1 : 0; }},
    {"largerEq", [](double a, double b) -> double { return a >= b ? 1 : 0; }},
    {"add", [](double a, double b) -> double { return a+b; }},
    {"multiply", [](double a, double b) -> double { return a*b; }},
    {"subtract", [](double a, double b) -> double { return a-b; }},
    {"divide", [](double a, double b) -> double { return a/b; }}};

typedef double(*ternaryFn)(double,double,double);
static const QMap<QString, ternaryFn> ternaryFuncs {
    {"fma", &fma},
    {"conditional", [](double a, double b, double c) -> double { return abs(a) > 1e-9 ? b : c; }}};

/*-------------------------------------------*/

class Ohm {
public:
    virtual ~Ohm() {}
    virtual double get() = 0;
    Q_INVOKABLE bool isOhm() {return true;}
    qint16 v16b() {
        double d = this->get() * 3276.7;
        d += 0.5 - (d < 0);
        d = qBound(-32768.0, d, 32767.0);
        return static_cast<qint16>(d);
    }
};
Q_DECLARE_INTERFACE(Ohm, "org.ohm.studio.Ohm")



/*-------------------------------------------*/

class Val : public QObject, public Ohm {
    Q_OBJECT
    Q_INTERFACES(Ohm)
public:
    Q_INVOKABLE Val(double _val, QObject *parent) : QObject(parent), val(_val){
        this->setObjectName("Ohm");
    }
    double get() { return val; }
    void set(double _val) { val = _val; }
    Q_INVOKABLE void inc() {
        val = val + 1;
    }
protected:
    double val;
};

/*-------------------------------------------*/

class Backend : public QObject {
    Q_OBJECT
    Val t;
    QMap<long, Val*> controls;
    Ohm *outL, *outR;

public:
    Backend(QObject *parent) : QObject(parent), t(0,this), outL(nullptr), outR(nullptr) {}

    Q_INVOKABLE Val* time() {
        return &t;
    }

    Q_INVOKABLE Ohm* out(long i) {
        return i ? outR : outL;
    }

    Q_INVOKABLE void out(long i, QObject *_out) {
        Ohm *out = qobject_cast<Ohm*>(_out);
        if (i) outR = out;
        else outL = out;
    }

    Q_INVOKABLE void control(long id, double val) {
        if (controls.contains(id)) controls[id]->set(val);
        else controls[id] = new Val(val,this);
    }

    Q_INVOKABLE Val* control(long id) {
        if (!controls.contains(id))
            controls[id] = new Val(0, this);
        return controls[id];
    }

    Q_INVOKABLE QList<QString> unaryFns() { return unaryFuncs.keys(); }
    Q_INVOKABLE QList<QString> binaryFns() { return binaryFuncs.keys(); }
    Q_INVOKABLE QList<QString> ternaryFns() { return ternaryFuncs.keys(); }

    void registerTypes(QQmlContext *root);
};

static Backend *backend;

/*-------------------------------------------*/

class Func : public QObject, public Ohm {
    Q_INTERFACES(Ohm)
public:
    double lastT;
    double lastEval;
    Func(QObject *parent) : QObject(parent), lastT(-1) {
        this->setObjectName("Ohm");
    }
    virtual double next() = 0;
    //double get();
    double get() {
        double t = backend->time()->get();
        if (t - lastT < 0.0001) return lastEval;
        lastEval = this->next();
        lastT = t;
        return lastEval;
    }
};
Q_DECLARE_INTERFACE(Func, "org.ohm.studio.Func")


class Sinusoid : public Func {
    Q_OBJECT
    Q_INTERFACES(Ohm Func)
public:
    Q_INVOKABLE Sinusoid(QObject *_f, QObject *parent) : Func(parent), f(qobject_cast<Ohm*>(_f)), phase(0) {}
    double next() {
        phase += f->get();
        return sin(phase);
    }
private:
    Ohm *f;
    double phase;
};

/*-------------------------------------------*/

class UnaryOp : public Func {
    Q_OBJECT
    Q_INTERFACES(Ohm Func)
public:
    Q_INVOKABLE UnaryOp(QString _fn, QObject *_arg, QObject *parent) : Func(parent), fn(unaryFuncs[_fn]), arg(qobject_cast<Ohm*>(_arg)) {}
    double next() {
        return fn(arg->get());
    }
protected:
    unaryFn fn;
    Ohm *arg;
};

/*-------------------------------------------*/

class BinaryOp : public Func {
    Q_OBJECT
    Q_INTERFACES(Ohm Func)
public:
    Q_INVOKABLE BinaryOp(QString _fn, QObject *_arg1, QObject *_arg2, QObject *parent) : Func(parent),
        fn(binaryFuncs[_fn]), arg1(qobject_cast<Ohm*>(_arg1)), arg2(qobject_cast<Ohm*>(_arg2))  {}
    double next() {
        return fn(arg1->get(), arg2->get());
    }
protected:
    binaryFn fn;
    Ohm *arg1, *arg2;
};

/*-------------------------------------------*/

class TernaryOp : public Func {
    Q_OBJECT
    Q_INTERFACES(Ohm Func)
public:
    Q_INVOKABLE TernaryOp(QString _fn, QObject *_arg1, QObject *_arg2, QObject *_arg3, QObject *parent) : Func(parent), fn(ternaryFuncs[_fn]),
        arg1(qobject_cast<Ohm*>(_arg1)), arg2(qobject_cast<Ohm*>(_arg2)), arg3(qobject_cast<Ohm*>(_arg3)) {}
    double next() {
        return fn(arg1->get(), arg2->get(), arg3->get());
    }
protected:
    ternaryFn fn;
    Ohm *arg1, *arg2, *arg3;
};

/*-------------------------------------------*/

void fillBuffer(short *buf, qint64 nframes) {
    Ohm *outL = backend->out(0);
    Ohm *outR = backend->out(1);
    Val *time = backend->time();

    for (int i = 0; i < nframes; i+= 1) {
        *buf++ = outL ? outL->v16b() : 0;
        *buf++ = outR ? outR->v16b() : 0;
        time->inc();
        //qDebug() << time->get() << *(buf-2) << *(buf-1);
    }
}

void initBackend(QGuiApplication *app, QQmlContext *root) {
    backend = new Backend(app);

    QQmlEngine *engine = root->engine();
    QJSValue g = engine->globalObject();

    qRegisterMetaType<Ohm*>("Ohm*");
    qRegisterMetaType<Backend*>("Backend*");
    qRegisterMetaType<Val*>("Val*");
    qRegisterMetaType<Func*>("Func*");
    qRegisterMetaType<Sinusoid*>("Sinusoid*");
    qRegisterMetaType<UnaryOp*>("UnaryOp*");
    qRegisterMetaType<BinaryOp*>("BinaryOp*");
    qRegisterMetaType<TernaryOp*>("TernaryOp*");
    qmlRegisterInterface<Ohm>("Ohm");
    qmlRegisterInterface<Func>("Func");

    g.setProperty("Backend",engine->newQObject(backend));
    g.setProperty("Val",engine->newQMetaObject(&Val::staticMetaObject));
    g.setProperty("Sinusoid",engine->newQMetaObject(&Sinusoid::staticMetaObject));
    g.setProperty("UnaryOp",engine->newQMetaObject(&UnaryOp::staticMetaObject));
    g.setProperty("BinaryOp",engine->newQMetaObject(&BinaryOp::staticMetaObject));
    g.setProperty("TernaryOp",engine->newQMetaObject(&TernaryOp::staticMetaObject));
}


#include "backend.moc"

