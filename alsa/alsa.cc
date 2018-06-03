#include <node.h>
#include <node_object_wrap.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <alsa/asoundlib.h>
#include <sys/time.h>

#define ErrorCheck(STMT)					\
  if ((err = (STMT)) < 0) {					\
    printf(#STMT " error %d: %s\n", err, snd_strerror(err));	\
    args.GetReturnValue().Set(Undefined(isolate));		\
    return;							\
  }

namespace alsa {

  using v8::Function;
  using v8::FunctionTemplate;
  using v8::FunctionCallbackInfo;
  using v8::Isolate;
  using v8::Local;
  using v8::Object;
  using v8::String;
  using v8::Value;
  using v8::Persistent;
  using v8::Number;
  using v8::Context;
  using v8::ArrayBuffer;
  using v8::Int32Array;
  
  class Sound : public node::ObjectWrap {
  public:
    static void Init(v8::Local<v8::Object> exports);
    explicit Sound(snd_pcm_t *handle, snd_output_t *output);
    snd_pcm_t *handle;
    snd_output_t *output;
    int started;
    snd_pcm_uframes_t viewOffset;
    snd_pcm_uframes_t viewFrames;
  private:
    ~Sound();
    static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
    static void WriteBuffer(const v8::FunctionCallbackInfo<v8::Value>& args);
    static void Commit(const v8::FunctionCallbackInfo<v8::Value>& args);
    static v8::Persistent<v8::Function> constructor;    
  };

  Persistent<Function> Sound::constructor;

  Sound::Sound(snd_pcm_t *h, snd_output_t *o) {
    handle = h;
    output = o;
  }
  Sound::~Sound() {
    snd_pcm_close(handle);
  }

  void Sound::Init(Local<Object> exports) {
    Isolate* isolate = exports->GetIsolate();
    Local<FunctionTemplate> tpl = FunctionTemplate::New(isolate, New);
    tpl->SetClassName(String::NewFromUtf8(isolate, "Sound"));
    tpl->InstanceTemplate()->SetInternalFieldCount(4);
    NODE_SET_PROTOTYPE_METHOD(tpl, "writeBuffer", WriteBuffer);
    NODE_SET_PROTOTYPE_METHOD(tpl, "commit", Commit);
    constructor.Reset(isolate, tpl->GetFunction());
    exports->Set(String::NewFromUtf8(isolate, "Sound"),
		 tpl->GetFunction());
  }

  void Sound::New(const FunctionCallbackInfo<Value>& args) {

    Isolate* isolate = args.GetIsolate();
    if (!args.IsConstructCall()) {
      const int argc = 4;
      Local<Value> argv[argc] = { args[0], args[1], args[2], args[3] };
      Local<Context> context = isolate->GetCurrentContext();
      Local<Function> cons = Local<Function>::New(isolate, constructor);
      Local<Object> result =
        cons->NewInstance(context, argc, argv).ToLocalChecked();
      args.GetReturnValue().Set(result);
      return;
    }
    
    int err;
    snd_pcm_t *handle;
    snd_output_t *output = NULL;
    snd_pcm_hw_params_t *hwparams;
    snd_pcm_sw_params_t *swparams;

    char device[50];
    args[0]->ToString()->WriteUtf8(device);
    int rate = args[1]->IntegerValue();
    int period_size = args[2]->IntegerValue();
    int buffer_size = args[3]->IntegerValue();
    int thresh = (buffer_size / period_size) * period_size;

    ErrorCheck(snd_output_stdio_attach(&output, stdout, 0));
    ErrorCheck(snd_pcm_open(&handle, device, SND_PCM_STREAM_PLAYBACK, 0));
    
    snd_pcm_hw_params_alloca(&hwparams);
    ErrorCheck(snd_pcm_hw_params_any(handle, hwparams));
    ErrorCheck(snd_pcm_hw_params_set_rate_resample(handle, hwparams, 1));
    ErrorCheck(snd_pcm_hw_params_set_access(handle, hwparams, SND_PCM_ACCESS_MMAP_INTERLEAVED));
    ErrorCheck(snd_pcm_hw_params_set_format(handle, hwparams, SND_PCM_FORMAT_S32));
    ErrorCheck(snd_pcm_hw_params_set_channels(handle, hwparams, 2));
    ErrorCheck(snd_pcm_hw_params_set_rate(handle, hwparams, rate, 0));
    ErrorCheck(snd_pcm_hw_params_set_period_size(handle, hwparams, period_size, 0));
    ErrorCheck(snd_pcm_hw_params_set_buffer_size(handle, hwparams, buffer_size));
    ErrorCheck(snd_pcm_hw_params(handle, hwparams));
      
    snd_pcm_sw_params_alloca(&swparams);
    ErrorCheck(snd_pcm_sw_params_current(handle, swparams));
    ErrorCheck(snd_pcm_sw_params_set_start_threshold(handle, swparams, thresh));
    ErrorCheck(snd_pcm_sw_params_set_avail_min(handle, swparams, period_size));
    ErrorCheck(snd_pcm_sw_params(handle, swparams));

    snd_pcm_dump(handle, output);
    Sound *obj = new Sound(handle,output);
    obj->started = 1;
    obj->Wrap(args.This());
    args.GetReturnValue().Set(args.This());
  }


    
  void Sound::WriteBuffer(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    Sound* obj = ObjectWrap::Unwrap<Sound>(args.Holder());
    int err;
    const snd_pcm_channel_area_t *areas;
    snd_pcm_uframes_t offset, frames, period_size, buffer_size;
    snd_pcm_sframes_t avail, target;
    ErrorCheck(snd_pcm_get_params(obj->handle, &buffer_size, &period_size));
    target = period_size;
    snd_pcm_state_t state = snd_pcm_state(obj->handle);
    if (state == SND_PCM_STATE_XRUN) {
      printf("UNDERRUN\n");
      ErrorCheck(snd_pcm_prepare(obj->handle));
      obj->started=1;
    } else if (state == SND_PCM_STATE_SUSPENDED) {
      printf("SUSPENDED???\n");
      exit(0);
    }
    avail = snd_pcm_avail_update(obj->handle);
    while (avail < target) {
      ErrorCheck(avail);
      if (obj->started) {
	obj->started=0;
	ErrorCheck(snd_pcm_start(obj->handle));
      } else {
	ErrorCheck(snd_pcm_wait(obj->handle,1));
      }
      avail = snd_pcm_avail_update(obj->handle);
    }
    frames = (avail / period_size) * period_size;
    ErrorCheck(snd_pcm_mmap_begin(obj->handle, &areas, &offset, &frames));
    Local<ArrayBuffer> locbuf = ArrayBuffer::New(isolate, areas[0].addr, frames*4*2);
    obj->viewOffset = offset;
    obj->viewFrames = frames;
    args.GetReturnValue().Set(Int32Array::New(locbuf, offset*4*2, frames*2));
  }

  void Sound::Commit(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    Sound* obj = ObjectWrap::Unwrap<Sound>(args.Holder());
    int err;
    snd_pcm_uframes_t frames = obj->viewFrames, offset = obj->viewOffset;
    snd_pcm_sframes_t ncommit = snd_pcm_mmap_commit(obj->handle, offset, frames);
    ErrorCheck(ncommit);
    if ((snd_pcm_uframes_t) ncommit != obj->viewFrames)
      printf("ERROR! committed %ld / %lu frames\n", ncommit, obj->viewFrames);
    args.GetReturnValue().Set(Undefined(isolate));     
  }

  void InitAll(Local<Object> exports, Local<Value> exportVal, void *exportData) {
    Sound::Init(exports);
  }
  
  NODE_MODULE(NODE_GYP_MODULE_NAME, InitAll);
}




