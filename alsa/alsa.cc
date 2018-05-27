#include <node.h>
#include <node_object_wrap.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <alsa/asoundlib.h>
#include <sys/time.h>

#define ErrorCheckExtra(STMT,EXTRA)			\
  if ((err = (STMT)) < 0) {				\
    EXTRA						\
    printf(#STMT " error %d: %s\n", err, snd_strerror(err));	\
    args.GetReturnValue().Set(Undefined(isolate));	\
    return;						\
  }

#define ErrorCheck(STMT) ErrorCheckExtra(STMT,;)
#define ContinueCheck(STMT) ErrorCheckExtra(STMT, if (err == -EAGAIN) continue;)

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
  
  class Sound : public node::ObjectWrap {
  public:
    static void Init(v8::Local<v8::Object> exports);
    explicit Sound(snd_pcm_t *handle, snd_output_t *output);
    snd_pcm_t *handle;
    snd_output_t *output;
  private:
    ~Sound();
    static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
    static void Write(const v8::FunctionCallbackInfo<v8::Value>& args);
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
    NODE_SET_PROTOTYPE_METHOD(tpl, "write", Write);
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
  
    obj->Wrap(args.This());
    args.GetReturnValue().Set(args.This());

  }

  void Sound::Write(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    Sound* obj = ObjectWrap::Unwrap<Sound>(args.Holder());

    Local<ArrayBuffer> arrayBuf = Local<ArrayBuffer>::Cast(args[0]);
    int32_t *samples = (int32_t*)arrayBuf->GetContents().Data();
    int left = arrayBuf->GetContents().ByteLength() / 8;
    
    int err;
    while (left > 0) {
      ContinueCheck(snd_pcm_mmap_writei(obj->handle, samples, left));
      samples += err * 2;
      left -= err;
    }

    args.GetReturnValue().Set(Undefined(isolate));    
  }

  void InitAll(Local<Object> exports) {
    Sound::Init(exports);
  }
  
  NODE_MODULE(NODE_GYP_MODULE_NAME, InitAll);
}




