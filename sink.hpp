#ifndef INCLUDE_SINK_HPP
#define INCLUDE_SINK_HPP

#include "conductor.hpp"
#include "function.hpp"

class Sink {
    public:
        Sink();
        Function *func;
        ma_rb ringbuf;
};


class ShaderSink : public QQuickItem, public Sink {
    Q_OBJECT
    Q_PROPERTY(QString status READ getStatus WRITE setStatus NOTIFY statusChanged)
    public:

        ShaderSink(QQuickItem *parent = nullptr);
        ~ShaderSink();
        Q_INVOKABLE void setFunc(QObject *function);
        Q_INVOKABLE void run(QString vert, QString frag);
        Q_INVOKABLE QString getStatus();
        Q_INVOKABLE void setStatus(QString s);
        QString vertCode, fragCode;
        bool recompile;
        QString status;
    signals:
        void statusChanged();
        
    protected:    
        QSGNode* updatePaintNode(QSGNode *, UpdatePaintNodeData *) override;
        
        
};

#endif
