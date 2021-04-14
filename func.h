#pragma once

#include <QObject>

#include "conductor.h"

class Func {
  public:
    Func() {};
    virtual double calc() { return 0; }
    double operator()() { return calc(); }
    operator double() { return calc(); }
};

class QFunc : public QObject, public Func {
    Q_OBJECT
  public:
    QFunc(QObject *parent = nullptr) : QObject(parent) {}
};

class MutableFunc : public QFunc {
    Q_OBJECT
  public:
    MutableFunc(QObject *parent = nullptr, double v = 0): QFunc(parent), val(v) {};
    double calc() override { return val; }   
    double val;
};

class CxxJIT;

class SymbolicFunc : public QFunc {
    Q_OBJECT
  public:
    Q_INVOKABLE SymbolicFunc(QObject *parent = nullptr);
    Q_INVOKABLE ~SymbolicFunc();
    Q_INVOKABLE void setVar(QString var, QVariant value);
    Q_INVOKABLE void compile(QString calc);
    double calc() override;
  private:
    QString name;
    Func nullfunc;
    QHash<QString,double> variables;
    QHash<QString,Func*> inFuncs;
    QHash<QString,std::vector<double>> sequences;
    CxxJIT *jit;
    double(*compiled)();
    double curVoltage;
    quint64 ticks;
    
};

