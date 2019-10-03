#ifndef INCLUDE_FUNCTION_HPP
#define INCLUDE_FUNCTION_HPP

#include "common.hpp"

typedef exprtk::ifunction<V> IFunction;

class Function : public QObject, public IFunction {
    Q_OBJECT
public:
    using IFunction::operator();
    Function();
    virtual V eval() = 0;
    V operator()() {
        return eval();
    }
    virtual Q_INVOKABLE QString repr() { return "Function()"; }
};

class NullFunction : public Function {
    Q_OBJECT
public:
    NullFunction();
    V eval() override { return 0; }
    V operator()() override { return 0; }
    Q_INVOKABLE QString repr() override { return "NullFunction()"; }
};

class BufferFunction : public Function {
    Q_OBJECT
public:
    QQueue<V> buffer;
    BufferFunction();
    Q_INVOKABLE V eval() override;
    void put(V val) {
        buffer.enqueue(val);
    }
    Q_INVOKABLE QString repr() override { return "BufferFunction()"; }
};


typedef exprtk::symbol_table<V> SymbolTable;
typedef exprtk::parser<V> Parser;
typedef exprtk::expression<V> Expression;

class SymbolicFunction : public Function {
    Q_OBJECT
    QString name;
    QString expstr;
    NullFunction nullfunc;
    QHash<QString,V*> variables;
    QHash<QString,Function*> refs;
    SymbolTable st;
    SymbolTable unknowns;
    Parser par;
    Expression expr;
    V curVoltage;
    long long ticks;

public:
    Q_INVOKABLE SymbolicFunction(QString label, QString expression, QJSValue funcRefs);
    Q_INVOKABLE void setVar(QString var, V value);
    Q_INVOKABLE void setFuncRef(QString fname, QJSValue funcRef);
    Q_INVOKABLE V eval() override;
    Function* function;
    Q_INVOKABLE QString repr() override {
        QStringList varstr;
        foreach (QString var, variables.keys())
            varstr << QString("%1 = %2").arg(var).arg(*(variables[var]));
        QStringList refstr;
        foreach (QString name, refs.keys())
            refstr << QString("%1 = %2").arg(name, refs[name]->repr());
        return QString("name: %1 | expr: { %2 } | vars: (%3) | refs: (%4)").arg(name, expstr, varstr.join("; "), refstr.join("; "));
    }

};


#endif
