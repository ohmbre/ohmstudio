//////////////////////////////////////////////////////////////////////////////
//
// NodeCoreAudio.cpp : Main module source, declares all exports
// 
//////////////////////////////////////////////////////////////////////////////

#include <v8.h>
using namespace v8;
#include <node.h>

#include <string>
#include "AudioEngine.h"
#include <stdio.h>

void InitAll(Handle<Object> target) {
    Audio::AudioEngine::Init( target );

    Nan::SetMethod(target, "createAudioEngine", Audio::AudioEngine::NewInstance);
    
    target->Set( Nan::New<String>("sampleFormatFloat32").ToLocalChecked(), Nan::New<Number>(1));
    target->Set( Nan::New<String>("sampleFormatInt32").ToLocalChecked(), Nan::New<Number>(2) );
    target->Set( Nan::New<String>("sampleFormatInt24").ToLocalChecked(), Nan::New<Number>(4) );
    target->Set( Nan::New<String>("sampleFormatInt16").ToLocalChecked(), Nan::New<Number>(8) );
    target->Set( Nan::New<String>("sampleFormatInt8").ToLocalChecked(), Nan::New<Number>(10) );
    target->Set( Nan::New<String>("sampleFormatUInt8").ToLocalChecked(), Nan::New<Number>(20) );
}

NODE_MODULE( NodeCoreAudio, InitAll );
