"use strict;"

import OhmEngine from "ohm.mjs"

const engine = OhmEngine();

SoundWorker.onMessage = (msg) => {
  engine.handle(msg);
}

SoundWorker.streams = engine.audioif.streams
