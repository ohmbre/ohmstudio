{
  'conditions': [
  ['OS=="linux"', {
  "targets": [
    {
      "target_name": "alsa",
      "sources": [ "alsa.cc" ],
      "libraries": [ "-lasound" ]
    }
  ]
  }]]
}