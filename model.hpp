#ifndef INCLUDE_MODEL_HPP
#define INCLUDE_MODEL_HPP

#include "function.hpp"

class Model : public QObject{
    Q_OBJECT
    Q_PROPERTY(QObject* parent READ parent CONSTANT)
    Q_PROPERTY(QVariantMap exports MEMBER exports)
    Q_PROPERTY(QString modelName READ getModelName CONSTANT)
    Q_PROPERTY(bool isModel READ isModel CONSTANT)
    public:

        bool isModel() { return true; }
       
        QString getModelName() {
            QString s = this->metaObject()->className();
            return s.split("_")[0];
        }
        
     signals:
        void viewChanged();
        void exportsChanged();
        
     private:
        QVariantMap exports;
};



#endif
