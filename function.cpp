#include "function.hpp"
#include "conductor.hpp"

Function::Function() : QObject(MADRE), IFunction(0) {}

NullFunction::NullFunction() : Function() {}
BufferFunction::BufferFunction() : Function(), buffer() {}

Q_INVOKABLE V BufferFunction::eval() {
    return buffer.dequeue();
}

Q_INVOKABLE SymbolicFunction::SymbolicFunction(QString label, QString expression, QJSValue funcRefs)
    : Function(), name(label), expstr(expression), variables(), curVoltage(0), ticks(maestro.ticks - 1) {

    st.add_constant("pi", M_PI);
    st.add_constant("tau", 2*M_PI);
    st.add_constant("V", 1);
    st.add_constant("s", FRAMES_PER_SEC);
    st.add_constant("ms", FRAMES_PER_SEC/1000);
    st.add_constant("mins", 60*FRAMES_PER_SEC);
    st.add_constant("Hz", 2*M_PI/FRAMES_PER_SEC);

    if (funcRefs.isArray()) {
        int nrefs = funcRefs.property("length").toInt();
        for (int r = 0 ; r < nrefs; r++) {
            QJSValue name = funcRefs.property(r);
            if (name.isString()) {
                st.add_function(name.toString().toStdString(), nullfunc);
                refs[name.toString()] = &nullfunc;
            }
        }
    }

    expr.register_symbol_table(unknowns);
    expr.register_symbol_table(st);
    par.enable_unknown_symbol_resolver();
    if (!par.compile(expression.toStdString(), expr))
        qDebug() << "Error compiling {" << expstr << "}" << QString::fromStdString(par.error());

    std::vector<std::string> variable_list;
    unknowns.get_variable_list(variable_list);
    for (std::string name : variable_list) {
        V& val = unknowns.variable_ref(name);
        variables[QString::fromStdString(name)] = &val;
    }
}


Q_INVOKABLE void SymbolicFunction::setVar(QString name, V value) {
    if (variables.contains(name))
        *variables[name] = value;
}

Q_INVOKABLE void SymbolicFunction::setFuncRef(QString fname, QJSValue funcRef) {
    Function *func = funcRef.isNull() ? &nullfunc : qobject_cast<Function*>(funcRef.toQObject());
    st.remove_function(fname.toStdString());
    st.add_function(fname.toStdString(), *func);
    refs[fname] = func;
    if (!par.compile(expstr.toStdString(), expr))
        qDebug() << "error compiling:" << expstr;
}

Q_INVOKABLE V SymbolicFunction::eval() {
    if (ticks >= maestro.ticks)
        return curVoltage;
    curVoltage = expr.value();
    ticks = maestro.ticks;
    return curVoltage;
}
