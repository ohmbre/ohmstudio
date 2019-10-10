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

Q_INVOKABLE SymbolicFunction::SymbolicFunction(QString label, QString expression, QVariantMap stateVars)
    : Function(), name(label), expstr(expression), variables(), inFuncs(), sequences(), compiled(false), curVoltage(0), ticks(maestro.ticks - 1) {

    st.add_constant("pi", M_PI);
    st.add_constant("tau", 2*M_PI);
    st.add_constant("V", 1);
    st.add_constant("s", FRAMES_PER_SEC);
    st.add_constant("ms", FRAMES_PER_SEC/1000);
    st.add_constant("mins", 60*FRAMES_PER_SEC);
    st.add_constant("Hz", 2*M_PI/FRAMES_PER_SEC);

    for(QVariantMap::const_iterator i = stateVars.constBegin(); i != stateVars.constEnd(); ++i) {
        QString svname = i.key();
        variables[svname] = i.value().toDouble();
        st.add_variable(svname.toStdString(), variables[svname]);
    }


    /*if (funcRefs.isArray()) {
        int nrefs = funcRefs.property("length").toInt();
        for (int r = 0 ; r < nrefs; r++) {
            QJSValue name = funcRefs.property(r);
            if (name.isString()) {
                st.add_function(name.toString().toStdString(), nullfunc);
                refs[name.toString()] = &nullfunc;
            }
        }
    }*/

    //expr.register_symbol_table(unknowns);
    expr.register_symbol_table(st);
    //par.enable_unknown_symbol_resolver();
    //if (!par.compile(expression.toStdString(), expr))
    //    qDebug() << "Error compiling {" << expstr << "}" << QString::fromStdString(par.error());

    /*std::vector<std::string> variable_list;
    unknowns.get_variable_list(variable_list);
    for (std::string name : variable_list) {
        V& val = unknowns.variable_ref(name);
        variables[QString::fromStdString(name)] = &val;
    }*/

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
                qDebug() << "   line:" << err.line_no;
                qDebug() << "   column:" << err.column_no;
                qDebug() << "   token:" << err.token.value.c_str();
                qDebug() << "   srcloc:" << err.src_location.c_str();
                qDebug() << "   Position:" << err.token.position;
                qDebug() << "   Type: [" << err.mode << "]";
                qDebug() << "   Message:" << err.diagnostic.c_str();
                qDebug(QString("   Expr: %1").arg(expstr).toUtf8());
                qDebug(QString("   Position: ... %1 ...").arg(expstr.mid(err.token.position, 100)).toUtf8());
                break;
            }
        }
    }
}

Q_INVOKABLE void SymbolicFunction::addVar(QString vname) {
    variables[vname] = 0;
    st.add_variable(vname.toStdString(), variables[vname]);
}

Q_INVOKABLE void SymbolicFunction::addSeq(QString sname) {
    sequences[sname] = {0};
    st.add_vector(sname.toStdString(),sequences[sname].data(),sequences[sname].size());
}

Q_INVOKABLE void SymbolicFunction::addInFunc(QString fname) {
    st.add_function(fname.toStdString(), nullfunc);
    inFuncs[fname] = &nullfunc;
}


Q_INVOKABLE void SymbolicFunction::setVar(QString vname, V value) {
    if (variables.contains(vname))
        variables[vname] = value;
}

Q_INVOKABLE void SymbolicFunction::setSeq(QString sname, QVector<V> entries) {
    if (!sequences.contains(sname)) return;
    int curSize = sequences[sname].size();
    if (entries.size() == curSize) {
        for (int i = 0; i < curSize; i++)
            sequences[sname][i] = entries[i];
    } else {
        compiled = false;
        st.remove_vector(sname.toStdString());
        sequences[sname] = entries;
        st.add_vector(sname.toStdString(),sequences[sname].data(),sequences[sname].size());
        compile();
    }
}

Q_INVOKABLE void SymbolicFunction::setInFunc(QString fname, QJSValue funcRef) {
    Function *func;
    if (funcRef.isNull()) func = &nullfunc;
    else func = qobject_cast<Function*>(funcRef.toQObject());
    compiled = false;
    st.remove_function(fname.toStdString());
    st.add_function(fname.toStdString(), *func);
    inFuncs[fname] = func;
    compile();
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

