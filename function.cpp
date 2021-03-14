#include "function.hpp"
#include "external/tinycc/libtcc.h"

Function::Function() : QObject(QGuiApplication::instance()), IFunction(0) {}

NullFunction::NullFunction() : Function() {}
BufferFunction::BufferFunction() : Function(), curVoltage(0), ticks(maestro.ticks - 1), buffer() {}
MutableFunction::MutableFunction(V v) : Function(), val(v) {}

void BufferFunction::put(V val) {
    buffer.enqueue(val);
}

void BufferFunction::trim() {
    int period = PERIOD;
    while (buffer.size() > period)
        buffer.dequeue();
}

Q_INVOKABLE V BufferFunction::eval() {
    if (ticks >= maestro.ticks)
        return curVoltage;
    curVoltage = buffer.isEmpty() ? 0 : buffer.dequeue();
    ticks = maestro.ticks;
    return curVoltage;
}



Q_INVOKABLE SymbolicFunction::SymbolicFunction(const QString &label, const QString &expression)
    : Function(), name(label), expstr(expression), variables(), inFuncs(), sequences(), compiled(false), curVoltage(0), ticks(maestro.ticks - 1) {
    
    st.add_constant("pi", M_PI);
    st.add_constant("tau", 2*M_PI);
    st.add_constant("V", 1);
    st.add_variable("s", maestro.sym_s);
    st.add_variable("ms", maestro.sym_ms);
    st.add_variable("mins", maestro.sym_mins);
    st.add_variable("Hz", maestro.sym_hz);
    /*st.add_constant("s", maestro.sampleRate());
    st.add_constant("ms", maestro.sampleRate()/1000);
    st.add_constant("mins", 60*maestro.sampleRate());
    st.add_constant("Hz", 2*M_PI/maestro.sampleRate());*/
    expr.register_symbol_table(st);
}

Q_INVOKABLE void SymbolicFunction::compile() {
    if (par.compile(expstr.toStdString(), expr)) {
        compiled = true;
    } else {
        compiled = false;
        qDebug() << "---------- Compile Error(s) ----------";
        for (unsigned long i = 0; i < par.error_count(); i++) {
            ParseError err = par.get_error(i);
            qDebug().noquote() << i << ") " << err.diagnostic.c_str() << Qt::endl
                               << "   at position ...:" << expstr.mid((int)err.token.position, 50)
                               << "   full function dump: " << repr();
        }
    }
}




Q_INVOKABLE void SymbolicFunction::setVar(QString vname, QVariant value) {
    bool wasCompiled;
    if (value.canConvert<QVariantList>()) {
        QVariantList vlist = value.toList();
        QVector<V> seq;
        foreach(QVariant listval, vlist) {
            if (listval.canConvert<double>())
                seq << listval.toDouble();
            else seq << 0;
        }
        if (!sequences.contains(vname)) {
            sequences[vname] = seq;
            st.add_vector(vname.toStdString(),sequences[vname].data(), (size_t)sequences[vname].size());
        } else {
            int curSize = sequences[vname].size();
            if (seq.size() == curSize) {
                for (int i = 0; i < curSize; i++)
                    sequences[vname][i] = seq[i];
            } else {
                wasCompiled = compiled;
                compiled = false;
                st.remove_vector(vname.toStdString());
                sequences[vname] = seq;
                st.add_vector(vname.toStdString(),sequences[vname].data(), (size_t) sequences[vname].size());
                if (wasCompiled) compile();
            }
        }
    } else if (value.canConvert<double>()) {
        V val = value.toDouble();
        if (!variables.contains(vname)) {
            variables[vname] = val;
            st.add_variable(vname.toStdString(), variables[vname]);
        } else {
            variables[vname] = val;
        }
    } else if (value.isNull() || value.canConvert<Function*>()) {
        Function *func;
        if (value.isNull()) func = &nullfunc;
        else func = value.value<Function*>();
        if (!inFuncs.contains(vname)) {
            st.add_function(vname.toStdString(), *func);
            inFuncs[vname] = func;
        } else {
            wasCompiled = compiled;
            compiled = false;
            st.remove_function(vname.toStdString());
            st.add_function(vname.toStdString(), *func);
            inFuncs[vname] = func;
            if (wasCompiled) compile();
        }
    }

}



Q_INVOKABLE V SymbolicFunction::eval() {
    if (!compiled) return 0;
    if (ticks >= maestro.ticks)
        return curVoltage;
    curVoltage = expr.value();
    ticks = maestro.ticks;
    return curVoltage;
}

Q_INVOKABLE QString SymbolicFunction::repr() {
    QStringList varstr;
    foreach (QString var, variables.keys())
        varstr << QString("%1 = %2").arg(var).arg(variables[var]);
    QStringList refstr;
    foreach (QString fname, inFuncs.keys())
        refstr << QString("%1 = %2").arg(fname, inFuncs[fname]->repr());
    QStringList seqstr;
    foreach (QString sname, sequences.keys()) {
        QStringList valstr;
        foreach(V val, sequences[sname])
            valstr << QString::number(val);
        seqstr << QString("%1 = [%2]").arg(sname, valstr.join(","));
    }

    return QString("name: %1 | expr: { %2 } | vars: (%3) | seqs: (%4) | inFuncs: (%5) | compiled: %6").arg(name, expstr, varstr.join("; "), seqstr.join("; "), refstr.join("; "), QString::number(compiled));
}

