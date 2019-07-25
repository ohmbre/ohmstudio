#ifndef SOUNDWORKER_P_H
#define SOUNDWORKER_P_H

#include <QMutex>
#include <QWaitCondition>
#include <QQmlError>
#include <QQmlParserStatus>
#include <QThread>
#include <QJSValue>
#include <QUrl>
#include <QObject>
#include <QIODevice>
#include <QAudioOutput>
#include <QMetaObject>
#include <QVariant>
#include <QDebug>

#include <QtQml/private/qv4include_p.h>
#include <QtQml/private/qv4engine_p.h>
#include <QtQml/private/qv8engine_p.h>
#include <QtQml/private/qv4serialize_p.h>
#include <QtQml/private/qv4jscall_p.h>
#include <QtQml/private/qv4arraybuffer_p.h>



  
class SoundWorker;
class SoundWorkerEngine;
class SoundGenerator;

class SoundWorkerEnginePrivate : public QObject {
  Q_OBJECT
public:
  enum WorkerEventTypes { SoundDestroyEvent = QEvent::User + 100 };
  SoundWorkerEnginePrivate(QQmlEngine *eng);
  ~SoundWorkerEnginePrivate();
  QQmlEngine *qmlengine;
  QMutex m_lock;
  QWaitCondition m_wait;
  struct SoundScript : public QV8Engine {
    SoundScript(int id, SoundWorkerEnginePrivate *parent);
    ~SoundScript() override;
    SoundWorkerEnginePrivate *p = nullptr;
    QUrl source;
    SoundWorker *owner = nullptr;
    int id = -1;
  };
  QHash<int, SoundScript *> workers;
  QV4::ReturnedValue getWorker(SoundScript *);
  int m_nextId;
  static QV4::ReturnedValue method_sendMessage(const QV4::FunctionObject *, const QV4::Value *thisObject, const QV4::Value *argv, int argc);
signals:
  void stopThread();
protected:  
  bool event(QEvent *) override;
private:
  void processMessage(int, const QString &);
  void processLoad(int, const QUrl &);
  void reportScriptException(SoundScript *, const QQmlError &error);
  SoundGenerator *m_genny;
};

class SoundWorkerEngine : public QThread
{
  Q_OBJECT
public:

  SoundWorkerEngine(QQmlEngine *parent = nullptr);
  ~SoundWorkerEngine();

  int registerWorkerScript(SoundWorker *);
  void removeWorkerScript(int);
  void executeUrl(int, const QUrl &);
  void sendMessage(int, const QString &);
  void run() override;

  SoundWorkerEnginePrivate *d;
  
};

class QQmlV4Function;
class QQmlV4Handle;
class SoundWorker : public QObject, public QQmlParserStatus
{
  Q_OBJECT
  Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)

  Q_INTERFACES(QQmlParserStatus)
public:
  SoundWorker(QObject *parent = nullptr);
  ~SoundWorker();
  
  QUrl source() const;
  void setSource(const QUrl &);
  				
public Q_SLOTS:
  void sendMessage(QQmlV4Function*);

Q_SIGNALS:
  void sourceChanged();
  void message(const QQmlV4Handle &messageObject);

protected:
  void classBegin() override;
  void componentComplete() override;
  bool event(QEvent *) override;
    
private:
  SoundWorkerEngine *engine();
  SoundWorkerEngine *m_engine;
  int m_scriptId;
  QUrl m_source;
  bool m_componentComplete;
};

class SoundDataEvent : public QEvent
{
public:
  enum Type { WorkerData = QEvent::User };
  SoundDataEvent(int workerId, const QString &data);
  virtual ~SoundDataEvent();
  int workerId() const;
  QString data() const;
private:
  int m_id;
  QString m_data;
};

class SoundLoadEvent : public QEvent
{
public:
  enum Type { WorkerLoad = SoundDataEvent::WorkerData + 1 };
  SoundLoadEvent(int workerId, const QUrl &url);
  int workerId() const;
  QUrl url() const;
private:
  int m_id;
  QUrl m_url;
};

class SoundRemoveEvent : public QEvent
{
public:
  enum Type { WorkerRemove = SoundLoadEvent::WorkerLoad + 1 };
  SoundRemoveEvent(int workerId);
  int workerId() const;
private:
  int m_id;
};

class SoundErrorEvent : public QEvent
{
public:
  enum Type { WorkerError = SoundRemoveEvent::WorkerRemove + 1 };
  SoundErrorEvent(const QQmlError &error);
  QQmlError error() const;
  
private:
  QQmlError m_error;
};


class SoundGenerator : public QIODevice {
public:
  SoundGenerator(SoundWorkerEnginePrivate::SoundScript *m_script);
  ~SoundGenerator();
  qint64 readData(char *data, qint64 maxSize);
  qint64 writeData(const char *data, qint64 len);
private:
  QAudioOutput *m_output;
  SoundWorkerEnginePrivate::SoundScript *m_script;
};

#endif 
