#include "function.hpp"

Function::Function() : QObject(QGuiApplication::instance()), IFunction(0) {}

NullFunction::NullFunction() : Function() {}
BufferFunction::BufferFunction() : Function(), buffer() {}

Q_INVOKABLE V BufferFunction::eval() {
    return buffer.dequeue();
}

/*struct Resolver : public Parser::unknown_symbol_resolver {
    bool process(const std::string &symbol, SymbolTable &st, double &default_value, std::string &error_message) {
        bool result = false;
        if (symbol.ends_with("_seq")) {
            st.add_variable(symbol
        }
    }
};*/

Q_INVOKABLE SymbolicFunction::SymbolicFunction(QString label, QString expression)
    : Function(), name(label), expstr(expression), variables(), inFuncs(), sequences(), compiled(false), curVoltage(0), ticks(maestro.ticks - 1) {

    st.add_constant("pi", M_PI);
    st.add_constant("tau", 2*M_PI);
    st.add_constant("V", 1);
    st.add_constant("s", FRAMES_PER_SEC);
    st.add_constant("ms", FRAMES_PER_SEC/1000);
    st.add_constant("mins", 60*FRAMES_PER_SEC);
    st.add_constant("Hz", 2*M_PI/FRAMES_PER_SEC);

    expr.register_symbol_table(st);

}

Q_INVOKABLE void SymbolicFunction::compile() {
    if (par.compile(expstr.toStdString(), expr)) {
        compiled = true;
    } else {
        compiled = false;
        for (unsigned long i = 0; i < par.error_count(); i++) {
            ParseError err = par.get_error(i);
            if (err.mode != exprtk::parser_error::e_symtab && !err.diagnostic.starts_with("ERR193 ")) {
                qDebug() << "Compile Error";
                qDebug() << "   token:" << err.token.value.c_str();
                qDebug() << "   Position:" << err.token.position;
                qDebug() << "   Message:" << err.diagnostic.c_str();
                qDebug(QString("   Expr: %1").arg(expstr).toUtf8());
                qDebug(QString("   Position: ... %1 ...").arg(expstr.mid(err.token.position, 50)).toUtf8());
                qDebug(repr().toUtf8());
                break;
            }
        }
    }
}




Q_INVOKABLE void SymbolicFunction::setVar(QString vname, QVariant value) {
    bool wasCompiled;
    if (value.canConvert(QMetaType::QVariantList)) {
        QVariantList vlist = value.toList();
        QVector<V> seq;
        foreach(QVariant listval, vlist) {
            if (listval.canConvert(QMetaType::Double))
                seq << listval.toDouble();
            else seq << 0;
        }
        if (!sequences.contains(vname)) {
            sequences[vname] = seq;
            st.add_vector(vname.toStdString(),sequences[vname].data(),sequences[vname].size());
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
                st.add_vector(vname.toStdString(),sequences[vname].data(),sequences[vname].size());
                if (wasCompiled) compile();
            }
        }
    } else if (value.canConvert(QMetaType::Double)) {
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

