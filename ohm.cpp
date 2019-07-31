#include "ohm.h"

#define PI 3.14159265358979323846
#define TAU 6.283185307179586

class Ticker {
public:
    Ticker() {
        t = 0;
    }
    void tick() {
        t++;
    }
    long now() {
        return t;
    }
private:
    long t;
};

class Ohm {
public:
    Ohm(Ticker *ticker) {
        t = ticker;
        lastTick = -1;
    }
    virtual ~Ohm() {}
    virtual double eval() = 0;
    virtual double v() {
        if (lastTick == t->now()) return lastEval;
        lastEval = eval();
        lastTick = t->now();
        return lastEval;
    }
private:
    Ticker *t;
    long lastTick;
    double lastEval;
};

class MutVal : public Ohm {
public:
    MutVal(Ticker *t, double v) : Ohm(t) {
        val = v;
    }
    void inc() {
        val++;
    }
    double eval() {
        return val;
    }
    double v() {
        return val;
    }
private:
    double val;
};

class Sinusoid : public Ohm {
    Sinusoid(Ticker *t, Ohm *freq) : Ohm(t) {
        f = freq;
        phase = 0;
    }
    double eval() {
        phase += f->v();
        return fmod(phase,TAU) / PI - 1;
    }
private:
    Ohm *f;
    double phase;
};



Ohms::Ohms()
{

}
