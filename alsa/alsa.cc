#include <node.h>
#include <node_object_wrap.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <alsa/asoundlib.h>
#include <sys/time.h>

#define QCX(STMT,EXTRA,RET)					\
  if ((err = (STMT)) < 0) {					\
    printf(#STMT " error %d: %s\n", err, snd_strerror(err));	\
    EXTRA;							\
    return RET;							\
  }

#define SETARGS  args.GetReturnValue().Set(Undefined(isolate));
#define QCA(STMT) QCX(STMT,SETARGS,)
#define QC(STMT) QCX(STMT,,err)

int pcm_config(snd_pcm_t *pcm, int rate, int period_size, int buffer_size, int thresh) {

  int err;
  
  snd_pcm_hw_params_t *hwparams;
  snd_pcm_hw_params_alloca(&hwparams);
  QC(snd_pcm_hw_params_any(pcm, hwparams));
  QC(snd_pcm_hw_params_set_rate_resample(pcm, hwparams, 1));
  QC(snd_pcm_hw_params_set_access(pcm, hwparams, SND_PCM_ACCESS_MMAP_INTERLEAVED));
  QC(snd_pcm_hw_params_set_format(pcm, hwparams, SND_PCM_FORMAT_S32));
  QC(snd_pcm_hw_params_set_channels(pcm, hwparams, 2));
  QC(snd_pcm_hw_params_set_rate(pcm, hwparams, rate, 0));
  QC(snd_pcm_hw_params_set_period_size(pcm, hwparams, period_size, 0));
  QC(snd_pcm_hw_params_set_buffer_size(pcm, hwparams, buffer_size));
  QC(snd_pcm_hw_params(pcm, hwparams));

  return 0;
  
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
    explicit Sound(snd_pcm_t *playback, snd_output_t *output);
    snd_pcm_t *playback, *capture;
    snd_output_t *output;
    int started;
    snd_pcm_uframes_t viewOffset,viewFrames,periodSize;

  private:
    ~Sound();
    static void New(const v8::FunctionCallbackInfo<v8::Value>& args);
    static void WriteBuffer(const v8::FunctionCallbackInfo<v8::Value>& args);
    static void Commit(const v8::FunctionCallbackInfo<v8::Value>& args);
    static v8::Persistent<v8::Function> constructor;    
  };

  Persistent<Function> Sound::constructor;

  Sound::Sound(snd_pcm_t *h, snd_output_t *o) {
    playback = h;
    output = o;
  }
  Sound::~Sound() {
    snd_pcm_close(playback);
    snd_pcm_close(capture);
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
    snd_pcm_t *playback,*capture;
    snd_output_t *output = NULL;
    int rate = args[1]->IntegerValue();
    int period_size = args[2]->IntegerValue();
    int buffer_size = args[3]->IntegerValue();
    int thresh = (buffer_size / period_size) * period_size;
    
    char device[50];
    args[0]->ToString()->WriteUtf8(device);
    
    QCA(snd_output_stdio_attach(&output, stdout, 0));
    QCA(snd_pcm_open(&playback, device, SND_PCM_STREAM_PLAYBACK, 0));
    QCA(snd_pcm_open(&capture, device, SND_PCM_STREAM_CAPTURE, 0));
    QCA(pcm_config(playback, rate, period_size, buffer_size, thresh));
    QCA(pcm_config(capture, rate, period_size, buffer_size, thresh));
    
    snd_pcm_dump(playback, output);
    snd_pcm_dump(capture, output);
    
    Sound *obj = new Sound(playback,output);
    obj->periodSize = period_size;
    obj->started = 1;
    obj->Wrap(args.This());
    args.GetReturnValue().Set(args.This());
  }
  
    
  void Sound::WriteBuffer(const FunctionCallbackInfo<Value>& args) {
    Isolate *isolate = args.GetIsolate();
    Sound* obj = ObjectWrap::Unwrap<Sound>(args.Holder());
    int err;
    const snd_pcm_channel_area_t *areas;
    snd_pcm_uframes_t offset, frames;
    snd_pcm_sframes_t avail, target;
    target = obj->periodSize;
    snd_pcm_state_t state = snd_pcm_state(obj->playback);
    if (state == SND_PCM_STATE_XRUN) {
      printf("UNDERRUN\n");
      QCA(snd_pcm_prepare(obj->playback));
      obj->started=1;
    } else if (state == SND_PCM_STATE_SUSPENDED) {
      printf("SUSPENDED???\n");
      exit(0);
    }
    avail = snd_pcm_avail_update(obj->playback);
    while (avail < target) {
      QCA(avail);
      if (obj->started) {
	obj->started=0;
	QCA(snd_pcm_start(obj->playback));
      } else {
	QCA(snd_pcm_wait(obj->playback,1));
      }
      avail = snd_pcm_avail_update(obj->playback);
    }
    frames = (avail / obj->periodSize) * obj->periodSize;
    QCA(snd_pcm_mmap_begin(obj->playback, &areas, &offset, &frames));
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
    snd_pcm_sframes_t ncommit = snd_pcm_mmap_commit(obj->playback, offset, frames);
    QCA(ncommit);
    if ((snd_pcm_uframes_t) ncommit != obj->viewFrames)
      printf("ERROR! committed %ld / %lu frames\n", ncommit, obj->viewFrames);
    args.GetReturnValue().Set(Undefined(isolate));     
  }

  void InitAll(Local<Object> exports, Local<Value> exportVal, void *exportData) {
    Sound::Init(exports);
  }
  
  NODE_MODULE(NODE_GYP_MODULE_NAME, InitAll);
}




