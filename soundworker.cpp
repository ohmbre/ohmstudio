#include "soundworker.h"
#include <private/qqmlengine_p.h>
#include <private/qqmlexpression_p.h>

#include <QtCore/qcoreevent.h>
#include <QtCore/qcoreapplication.h>
#include <QtCore/qdebug.h>
#include <QtQml/qjsengine.h>
#include <QtCore/qmutex.h>
#include <QtCore/qwaitcondition.h>
#include <QtCore/qfile.h>
#include <QtCore/qdatetime.h>
#include <QtQml/qqmlinfo.h>
#include <QtQml/qqmlfile.h>

SoundGenerator::SoundGenerator(SoundWorkerEnginePrivate::SoundScript *script) {
  m_script = script;
  QAudioFormat format;
  format.setSampleRate(48000);
  format.setChannelCount(2);
  format.setSampleSize(32);
  format.setSampleType(QAudioFormat::Float);
  format.setCodec("audio/pcm");
  format.setByteOrder(QAudioFormat::LittleEndian);
  QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());
  if (!info.isFormatSupported(format)) {
    qWarning() << "hardware does not support requested pcm format. nearest: ";
    format = info.nearestFormat(format);
    qWarning() << format.sampleRate() << " " << format.channelCount() << " " << format.sampleSize() << " " << format.sampleType() << " " << format.codec() << " " << format.byteOrder();
  }
  setOpenMode(QIODevice::ReadWrite);
  m_output = new QAudioOutput(format,this);
  m_output->start(this);
}

qint64 SoundGenerator::readData(char *data, qint64 maxSize) {
  QV4::ExecutionEngine *v4 = QV8Engine::getV4(m_script);
  QV4::Scope scope(v4);
  QV4::ScopedString v(scope);

  QV4::ScopedObject worker(scope, v4->globalObject->get((v = v4->newString(QStringLiteral("SoundWorker")))));
  if (!worker) {
    qWarning() << "could not get SoundWorker global object from script";
    return 0;
  }
  
  QV4::ScopedObject streams(scope, worker->get((v = v4->newString(QStringLiteral("streams")))));
  if (!streams) {
    qWarning() << "could not get streams object from SoundWorker";
    return 0;
  }

  QV4::ScopedArrayObject output(scope, streams->get((v = v4->newString(QStringLiteral("out")))));
  if (!output) {
    qWarning() << "could not get out array from streams";
    return 0;
  }

  if (scope.hasException()) {
    QQmlError error = scope.engine->catchExceptionAsQmlError();
    qWarning() << "Generator Exception: " << error;
  }  
  
  QV4::Value outL = QV4::Value::fromReturnedValue(output->get(static_cast<quint32>(0)));
  QV4::Value outR = QV4::Value::fromReturnedValue(output->get(static_cast<quint32>(1)));
  
  float *buf = reinterpret_cast<float*>(data);
  qint64 nsamp = maxSize / 4;
  int i = 0;
  while (i < nsamp) {
    buf[i++] = static_cast<float>(QV4::RuntimeHelpers::toNumber(outL)/10.0f);
    buf[i++] = static_cast<float>(QV4::RuntimeHelpers::toNumber(outR)/10.0f);
    //qWarning() << buf[i-2];
    //qWarning() << buf[i-1];
  }

  return maxSize;
}

qint64 SoundGenerator::writeData(const char *, qint64 len) {
  return len;
}

SoundGenerator::~SoundGenerator() {
  if (m_output != nullptr) {
    m_output->stop();
    delete m_output;
  }
}
  

SoundWorkerEnginePrivate::SoundWorkerEnginePrivate(QQmlEngine *engine) : qmlengine(engine), m_nextId(0), m_genny(nullptr) { }

SoundWorkerEnginePrivate::~SoundWorkerEnginePrivate() {
  if (m_genny != nullptr) delete m_genny;
}

QV4::ReturnedValue SoundWorkerEnginePrivate::method_sendMessage(const QV4::FunctionObject *b,
								const QV4::Value *, const QV4::Value *argv, int argc) {
  QV4::Scope scope(b);
  SoundScript *script = static_cast<SoundScript *>(scope.engine->v8Engine);  
  QV4::ScopedValue v(scope, argc > 0 ? argv[0] : QV4::Value::undefinedValue());
  
  QString data = v->stringValue()->toQString();
  
  QMutexLocker locker(&script->p->m_lock);
  if (script && script->owner)
    QCoreApplication::postEvent(script->owner, new SoundDataEvent(0, data));
  
  return QV4::Encode::undefined();
}

bool SoundWorkerEnginePrivate::event(QEvent *event) {
    if (event->type() == (QEvent::Type)SoundDataEvent::WorkerData) {
        SoundDataEvent *workerEvent = static_cast<SoundDataEvent *>(event);
        processMessage(workerEvent->workerId(), workerEvent->data());
        return true;
    } else if (event->type() == (QEvent::Type)SoundLoadEvent::WorkerLoad) {
        SoundLoadEvent *workerEvent = static_cast<SoundLoadEvent *>(event);
        processLoad(workerEvent->workerId(), workerEvent->url());
        return true;
    } else if (event->type() == (QEvent::Type)SoundDestroyEvent) {
        emit stopThread();
        return true;
    } else if (event->type() == (QEvent::Type)SoundRemoveEvent::WorkerRemove) {
        QMutexLocker locker(&m_lock);
        SoundRemoveEvent *workerEvent = static_cast<SoundRemoveEvent *>(event);
        QHash<int, SoundScript *>::iterator itr = workers.find(workerEvent->workerId());
        if (itr != workers.end()) {
            delete itr.value();
            workers.erase(itr);
        }
        return true;
    } else {
        return QObject::event(event);
    }
}

void SoundWorkerEnginePrivate::processMessage(int id, const QString &data) {
    SoundScript *script = workers.value(id);
    if (!script)
        return;

    QV4::ExecutionEngine *v4 = QV8Engine::getV4(script);   
    QV4::Scope scope(v4);
    QV4::ScopedString v(scope);
    QV4::ScopedObject worker(scope, v4->globalObject->get((v = v4->newString(QStringLiteral("SoundWorker")))));
    QV4::ScopedFunctionObject onmessage(scope);
    if (worker)
        onmessage = worker->get((v = v4->newString(QStringLiteral("onMessage"))));

    if (!onmessage)
        return;

    QV4::ScopedValue value(scope, v4->newString(data));

    QV4::JSCallData jsCallData(scope, 1);
    *jsCallData->thisObject = v4->global();
    jsCallData->args[0] = value;
    onmessage->call(jsCallData);
    if (scope.hasException()) {
        QQmlError error = scope.engine->catchExceptionAsQmlError();
        reportScriptException(script, error);
    }
}

void SoundWorkerEnginePrivate::processLoad(int id, const QUrl &url) {
    if (url.isRelative())
        return;

    QString fileName = QQmlFile::urlToLocalFileOrQrc(url);

    SoundScript *script = workers.value(id);
    if (!script)
        return;

    QV4::ExecutionEngine *v4 = QV8Engine::getV4(script);
    
    script->source = url;

    if (fileName.endsWith(QLatin1String(".mjs"))) {
        auto moduleUnit = v4->loadModule(url);
        if (moduleUnit) {
            if (moduleUnit->instantiate(v4))
                moduleUnit->evaluate();
        } else {
            v4->throwError(QStringLiteral("Could not load module file"));
        }
    } else {
        QString error;
        QV4::Scope scope(v4);
        QScopedPointer<QV4::Script> program;
        program.reset(QV4::Script::createFromFileOrCache(v4, /*qmlContext*/nullptr, fileName, url, &error));
        if (program.isNull()) {
            if (!error.isEmpty())
                qWarning().nospace() << error;
            return;
        }

        if (!v4->hasException)
            program->run();
    }
  
    if (v4->hasException) {
        QQmlError error = v4->catchExceptionAsQmlError();
        reportScriptException(script, error);
    } else {
      m_genny = new SoundGenerator(script);      
    }
}

void SoundWorkerEnginePrivate::reportScriptException(SoundScript *script, const QQmlError &error) {
    QMutexLocker locker(&script->p->m_lock);
    if (script->owner)
        QCoreApplication::postEvent(script->owner, new SoundErrorEvent(error));
}

SoundDataEvent::SoundDataEvent(int workerId, const QString &data)
: QEvent((QEvent::Type)WorkerData), m_id(workerId), m_data(data) {}
SoundDataEvent::~SoundDataEvent(){}
int SoundDataEvent::workerId() const { return m_id; }
QString SoundDataEvent::data() const { return m_data; }

SoundLoadEvent::SoundLoadEvent(int workerId, const QUrl &url)
: QEvent((QEvent::Type)WorkerLoad), m_id(workerId), m_url(url) {}
int SoundLoadEvent::workerId() const { return m_id; }
QUrl SoundLoadEvent::url() const { return m_url; }

SoundRemoveEvent::SoundRemoveEvent(int workerId)
: QEvent((QEvent::Type)WorkerRemove), m_id(workerId) {}
int SoundRemoveEvent::workerId() const { return m_id; }

SoundErrorEvent::SoundErrorEvent(const QQmlError &error)
: QEvent((QEvent::Type)WorkerError), m_error(error) {}
QQmlError SoundErrorEvent::error() const { return m_error; }


SoundWorkerEngine::SoundWorkerEngine(QQmlEngine *parent) : QThread(parent), d(new SoundWorkerEnginePrivate(parent)) {
  d->m_lock.lock();
  connect(d, SIGNAL(stopThread()), this, SLOT(quit()), Qt::DirectConnection);
  start(QThread::LowestPriority);
  d->m_wait.wait(&d->m_lock);
  d->moveToThread(this);
  d->m_lock.unlock();
}

SoundWorkerEngine::~SoundWorkerEngine() {
    d->m_lock.lock();
    QCoreApplication::postEvent(d, new QEvent((QEvent::Type)SoundWorkerEnginePrivate::SoundDestroyEvent));
    d->m_lock.unlock();

    while (!isFinished()) {
        QCoreApplication::processEvents();
        yieldCurrentThread();
    }

    d->deleteLater();
}

SoundWorkerEnginePrivate::SoundScript::SoundScript(int id, SoundWorkerEnginePrivate *parent) : QV8Engine(new QV4::ExecutionEngine), p(parent), id(id) {
  m_v4Engine->v8Engine = this;
  initQmlGlobalObject();
  
  QV4::Scope scope(m_v4Engine);
  QV4::ScopedObject api(scope, scope.engine->newObject());
  QV4::ScopedString name(scope, m_v4Engine->newString(QStringLiteral("sendMessage")));
  QV4::ScopedValue sendMessage(scope, QV4::FunctionObject::createBuiltinFunction(m_v4Engine, name, method_sendMessage, 1));
  api->put(QV4::ScopedString(scope, scope.engine->newString(QStringLiteral("sendMessage"))), sendMessage);
  m_v4Engine->globalObject->put(QV4::ScopedString(scope, scope.engine->newString(QStringLiteral("SoundWorker"))), api);
}

SoundWorkerEnginePrivate::SoundScript::~SoundScript() {
  delete m_v4Engine;
}
  
int SoundWorkerEngine::registerWorkerScript(SoundWorker *owner) {
  typedef SoundWorkerEnginePrivate::SoundScript SoundScript;
  SoundScript *script = new SoundScript(d->m_nextId++, d);
  
  script->owner = owner;
  
  d->m_lock.lock();
  d->workers.insert(script->id, script);
  d->m_lock.unlock();
  
  return script->id;
}

void SoundWorkerEngine::removeWorkerScript(int id) {
  SoundWorkerEnginePrivate::SoundScript *script = d->workers.value(id);
  if (script) {
    script->owner = nullptr;
    QCoreApplication::postEvent(d, new SoundRemoveEvent(id));
  }
}

void SoundWorkerEngine::executeUrl(int id, const QUrl &url) {
  QCoreApplication::postEvent(d, new SoundLoadEvent(id, url));
}

void SoundWorkerEngine::sendMessage(int id, const QString &data) {
  QCoreApplication::postEvent(d, new SoundDataEvent(id, data));
}

void SoundWorkerEngine::run() {
  d->m_lock.lock();
  d->m_wait.wakeAll();
  d->m_lock.unlock();
  exec();
  qDeleteAll(d->workers);
  d->workers.clear();
}


SoundWorker::SoundWorker(QObject *parent) : QObject(parent), m_engine(nullptr),
					    m_scriptId(-1), m_componentComplete(true) {}

SoundWorker::~SoundWorker() {
  if (m_scriptId != -1) m_engine->removeWorkerScript(m_scriptId);
}

QUrl SoundWorker::source() const {
  return m_source;
}

void SoundWorker::setSource(const QUrl &source) {
  if (m_source == source)
    return;
  
  m_source = source;
  
  if (engine())
    m_engine->executeUrl(m_scriptId, m_source);
  
  emit sourceChanged();
}

void SoundWorker::sendMessage(QQmlV4Function *args) {
  if (!engine()) {
    qWarning("QQuickWorkerScript: Attempt to send message before WorkerScript establishment");
    return;
  }
  
  QV4::Scope scope(args->v4engine());
  QV4::ScopedValue argument(scope, QV4::Value::undefinedValue());
  if (args->length() != 0)
    argument = (*args)[0];
  
  m_engine->sendMessage(m_scriptId, argument->stringValue()->toQString());
}

void SoundWorker::classBegin() {
  m_componentComplete = false;
}

static SoundWorkerEngine *globalSoundWorkerEngine = nullptr;

SoundWorkerEngine *SoundWorker::engine() {
  if (m_engine) return m_engine;
  if (m_componentComplete) {
    QQmlEngine *engine = qmlEngine(this);
    if (!engine) {
      qWarning("QQuickWorkerScript: engine() called without qmlEngine() set");
      return nullptr;
    }
    if (globalSoundWorkerEngine == nullptr)
      globalSoundWorkerEngine = new SoundWorkerEngine(engine);
    m_engine = globalSoundWorkerEngine;
    Q_ASSERT(m_engine);
    m_scriptId = m_engine->registerWorkerScript(this);
    
    if (m_source.isValid()) {
      m_engine->executeUrl(m_scriptId, m_source);
    }
    
    return m_engine;
  }
  return nullptr;
}

void SoundWorker::componentComplete() {
  m_componentComplete = true;
  engine();
}

bool SoundWorker::event(QEvent *event) {
  if (event->type() == (QEvent::Type)SoundDataEvent::WorkerData) {
    QQmlEngine *engine = qmlEngine(this);
    if (engine) {
      SoundDataEvent *workerEvent = static_cast<SoundDataEvent *>(event);
      QV4::Scope scope(engine->handle());
      QV4::ScopedValue value(scope, scope.engine->newString(workerEvent->data()));
      emit message(QQmlV4Handle(value));
    }
    return true;
  } else if (event->type() == (QEvent::Type)SoundErrorEvent::WorkerError) {
    SoundErrorEvent *workerEvent = static_cast<SoundErrorEvent *>(event);
    QQmlEnginePrivate::warning(qmlEngine(this), workerEvent->error());
    return true;
  } else {
    return QObject::event(event);
  }
}

