#include "func.h"
#include "audio.h"




Q_INVOKABLE void SymbolicFunc::setVar(QString vname, QVariant value) {
    if (value.canConvert<QVariantList>()) {
        QVariantList vlist = value.toList();
        std::vector<double> seq;
        for(auto &listval : vlist) {
            if (listval.canConvert<double>())
                seq.push_back(listval.toDouble());
            else seq.push_back(0);
        }
        sequences[vname] = seq;        
    } else if (value.canConvert<double>()) {       
        double val = value.toDouble();
        variables[vname] = val;
    } else if (value.isNull() || value.canConvert<QFunc*>()) {
        Func *func;
        if (value.isNull()) func = &nullfunc;
        else func = value.value<QFunc*>();
        inFuncs[vname] = func;
    }
    
}


Q_INVOKABLE double SymbolicFunc::calc() {
    if (!compiled) return 0;
    if (ticks >= maestro.ticks)
        return curVoltage;
    if (!compiled) curVoltage = 0;
    else {
        for (Func *f : inFuncs) (*f)();
        curVoltage = compiled();
    }
    ticks = maestro.ticks;
    return curVoltage;
}





#pragma push_macro("emit")
#undef emit
#include "external/cxx-jit.h"
#pragma pop_macro("emit")



QString jit_template = R"(
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <limits>
#include <algorithm>
#include <vector>
#define PI 0x1.921fb54442d18p+1
#define TAU 0x1.921fb54442d18p+2
#define pi PI
#define tau TAU
#define hz Hz
class Func {
public:
    Func();
    virtual double calc();
    double operator()() { return calc(); };
    operator double() { return calc(); }
};

extern "C" double s;
extern "C" double ms;
extern "C" double mins;
extern "C" double Hz;

using namespace std;

%1
)";


Q_INVOKABLE SymbolicFunc::SymbolicFunc(QObject *parent) : QFunc(parent), compiled(nullptr), curVoltage(0) {
    ticks = maestro.ticks - 1;
    jit = new CxxJIT();
}


Q_INVOKABLE void SymbolicFunc::compile(QString calc) {
    
    QStringList decls, vnames = variables.keys(), fnames = inFuncs.keys(), snames = sequences.keys();
    for (auto &name : vnames) {
        decls.append("extern \"C\" double "+name+";");
        jit->setSym(name.toStdString(),&variables[name]);   
    }
    for (auto &name : snames) {
        decls.append("extern \"C\" std::vector<double> "+name+";");
        jit->setSym(name.toStdString(),&sequences[name]);
    }
    for (auto &name : fnames) {
        jit->setSym("p_"+name.toStdString(),&inFuncs[name]);
        decls.append("extern \"C\" Func *p_"+name+";");        
        decls.append("#define "+name+" (*p_"+name+")");
    }

    jit->setSym("s", &maestro.sym_s);
    jit->setSym("ms", &maestro.sym_ms);
    jit->setSym("mins", &maestro.sym_mins);
    jit->setSym("Hz", &maestro.sym_hz);
    
    calc = calc.replace(QRegularExpression(R"(double\s+calc\s*\(\s*(void)*\s*\))"), R"(extern "C" double calc())");
    
    decls.append(calc);
    QString code = jit_template.arg(decls.join("\n"));
    
    if (jit->compile(code.toStdString()))
        compiled = (double(*)()) jit->getSym("calc");

    if (!compiled) {
        qDebug().noquote() << QString::fromStdString(jit->errorString());
        qDebug().noquote() << code;
    }
    

    
}




Q_INVOKABLE SymbolicFunc::~SymbolicFunc() {
    delete jit;
}




