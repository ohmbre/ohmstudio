#ifndef INCLUDE_FUNCTION_HPP
#define INCLUDE_FUNCTION_HPP

#include "conductor.hpp"
#ifndef M_PI
#define M_PI 0x1.921fb54442d18p+1
#endif

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
Q_DECLARE_INTERFACE(Function, "Function")



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
    V curVoltage;
    long long ticks;

    QQueue<V> buffer;
    BufferFunction();
    Q_INVOKABLE V eval() override;
    void put(V val);
    void trim();
    Q_INVOKABLE QString repr() override { return "BufferFunction()"; }
};

class MutableFunction : public Function {
        Q_OBJECT
public:
    V val;
    explicit MutableFunction(V v);
    V eval() override { return val; }
    V operator()() override { return val; }
    Q_INVOKABLE QString repr() override { return QString("MutableFunction(%1)").arg(val); }
};


typedef exprtk::symbol_table<V> SymbolTable;
typedef exprtk::parser<V> Parser;
typedef exprtk::expression<V> Expression;
typedef exprtk::vector_view<V> VectorView;
typedef exprtk::parser_error::type ParseError;


class SymbolicFunction : public Function {
    Q_OBJECT
    QML_ELEMENT
    QString name;
    QString expstr;
    NullFunction nullfunc;
    QHash<QString,V> variables;
    QHash<QString,Function*> inFuncs;
    QHash<QString,QVector<V>> sequences;
    SymbolTable st;
    Parser par;
    Expression expr;
    bool compiled;
    V curVoltage;
    long long ticks;

public:
    Q_INVOKABLE SymbolicFunction(const QString &label, const QString &expression);
    Q_INVOKABLE void setVar(QString var, QVariant value);
    Q_INVOKABLE void compile();
    Q_INVOKABLE V eval() override;
    Q_INVOKABLE QString repr() override;
};


#endif
