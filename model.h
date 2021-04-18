#pragma once

#include <QObject>
#include <QVariantMap>
#include <QQmlEngine>



class Model : public QObject{
    Q_OBJECT
    Q_PROPERTY(QObject* parent READ parent CONSTANT)
    Q_PROPERTY(QVariantMap exports MEMBER exports)
    Q_PROPERTY(QString modelName READ getModelName CONSTANT)
    Q_PROPERTY(bool isModel READ isModel CONSTANT)
    QML_ELEMENT
    public:

        bool isModel() { return true; }
       
        Q_INVOKABLE QString getModelName() {
            QString s = this->metaObject()->className();
            return s.split("_")[0];
        }
        
       
     private:
        QVariantMap exports;
};


