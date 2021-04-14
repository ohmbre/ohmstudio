#pragma once

#include <QObject>
#include <QQuickItem>

#include "external/miniaudio.h"
#include "conductor.h"
#include "audio.h"
#include "func.h"


class Sink {
    public:
        Sink();
        Func *func;
        ma_rb ringbuf;
};


class ShaderSink : public QQuickItem, public Sink {
    Q_OBJECT
    Q_PROPERTY(QString status READ getStatus WRITE setStatus NOTIFY statusChanged)
    QML_ELEMENT
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


