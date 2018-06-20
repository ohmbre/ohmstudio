#include <node.h>
#include <nan.h>
#include <QtGui>
#include <QObject>
#include <QTextCodec>
#include <QQuickStyle>
#include <uv.h>
#include "QApplication.h"

namespace Brig {

	using namespace v8;
	using namespace node;

	Nan::Persistent<Function> QApplicationWrap::constructor;

	QApplicationWrap::QApplicationWrap() : ObjectWrap()
	{
		app_argc = 0;
		app_argv = NULL;

		dispatcher = new BrigEventDispatcher;
		QGuiApplication::setEventDispatcher(dispatcher);
		QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
		QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

		app = new QGuiApplication(app_argc, app_argv);
		QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));

		QCoreApplication::addLibraryPath("/usr/lib64/qt5/qml");
		QCoreApplication::addLibraryPath("/usr/lib64/qt5/plugins");
		
		  
	}

	QApplicationWrap::~QApplicationWrap()
	{
		delete app;
		delete dispatcher;
	}

	NAN_MODULE_INIT(QApplicationWrap::Initialize) { 

		Local<String> name = Nan::New("QApplication").ToLocalChecked();

		/* Constructor template */
		Local<FunctionTemplate> tpl = Nan::New<FunctionTemplate>(QApplicationWrap::New);
//		Persistent<FunctionTemplate> tpl = Persistent<FunctionTemplate>::New(FunctionTemplate::New(QApplicationWrap::New));
		tpl->InstanceTemplate()->SetInternalFieldCount(1);  
		tpl->SetClassName(name);

		/* Prototype */
		Nan::SetPrototypeMethod(tpl, "setApplicationName", QApplicationWrap::setApplicationName);
		Nan::SetPrototypeMethod(tpl, "setStyle", QApplicationWrap::setStyle);

		constructor.Reset(tpl->GetFunction());

//		NanAssignPersistent(constructor, tpl->GetFunction());
//		constructor = Persistent<Function>::New(tpl->GetFunction());

		Nan::Set(target, name, Nan::New(constructor));
	}

	NAN_METHOD(QApplicationWrap::New) {

		QApplicationWrap *app_wrap = new QApplicationWrap();
		app_wrap->Wrap(info.This());

		info.GetReturnValue().Set(info.This());
	}

	NAN_METHOD(QApplicationWrap::setStyle) {

		// style name
		String::Utf8Value style(info[0]->ToString());

		QQuickStyle::setStyle(QString(*style));

		info.GetReturnValue().Set(Nan::Undefined());
	}

	NAN_METHOD(QApplicationWrap::setApplicationName) {

		// application name
		String::Utf8Value name(info[0]->ToString());

		QCoreApplication::setApplicationName(QString(*name));

		info.GetReturnValue().Set(Nan::Undefined());
	}
}
