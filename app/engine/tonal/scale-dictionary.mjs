import { EmptyPcset, pcset } from './pcset.mjs';

// SCALES
// Format: ["intervals", "name", "alias1", "alias2", ...]
const SCALES = [
    // 5-note scales
    ["1P 2M 3M 5P 6M", "major pentatonic", "pentatonic"],
    ["1P 3M 4P 5P 7M", "ionian pentatonic"],
    ["1P 3M 4P 5P 7m", "mixolydian pentatonic", "indian"],
    ["1P 2M 4P 5P 6M", "ritusen"],
    ["1P 2M 4P 5P 7m", "egyptian"],
    ["1P 3M 4P 5d 7m", "neopolitan major pentatonic"],
    ["1P 3m 4P 5P 6m", "vietnamese 1"],
    ["1P 2m 3m 5P 6m", "pelog"],
    ["1P 2m 4P 5P 6m", "kumoijoshi"],
    ["1P 2M 3m 5P 6m", "hirajoshi"],
    ["1P 2m 4P 5d 7m", "iwato"],
    ["1P 2m 4P 5P 7m", "in-sen"],
    ["1P 3M 4A 5P 7M", "lydian pentatonic", "chinese"],
    ["1P 3m 4P 6m 7m", "malkos raga"],
    ["1P 3m 4P 5d 7m", "locrian pentatonic", "minor seven flat five pentatonic"],
    ["1P 3m 4P 5P 7m", "minor pentatonic", "vietnamese 2"],
    ["1P 3m 4P 5P 6M", "minor six pentatonic"],
    ["1P 2M 3m 5P 6M", "flat three pentatonic", "kumoi"],
    ["1P 2M 3M 5P 6m", "flat six pentatonic"],
    ["1P 2m 3M 5P 6M", "scriabin"],
    ["1P 3M 5d 6m 7m", "whole tone pentatonic"],
    ["1P 3M 4A 5A 7M", "lydian #5P pentatonic"],
    ["1P 3M 4A 5P 7m", "lydian dominant pentatonic"],
    ["1P 3m 4P 5P 7M", "minor #7M pentatonic"],
    ["1P 3m 4d 5d 7m", "super locrian pentatonic"],
    // 6-note scales
    ["1P 2M 3m 4P 5P 7M", "minor hexatonic"],
    ["1P 2A 3M 5P 5A 7M", "augmented"],
    ["1P 3m 4P 5d 5P 7m", "minor blues", "blues"],
    ["1P 2M 3m 3M 5P 6M", "major blues"],
    ["1P 2M 4P 5P 6M 7m", "piongio"],
    ["1P 2m 3M 4A 6M 7m", "prometheus neopolitan"],
    ["1P 2M 3M 4A 6M 7m", "prometheus"],
    ["1P 2m 3M 5d 6m 7m", "mystery #1"],
    ["1P 2m 3M 4P 5A 6M", "six tone symmetric"],
    ["1P 2M 3M 4A 5A 7m", "whole tone"],
    // 7-note scales
    ["1P 2M 3M 4P 5d 6m 7m", "locrian major", "arabian"],
    ["1P 2m 3M 4A 5P 6m 7M", "double harmonic lydian"],
    ["1P 2M 3m 4P 5P 6m 7M", "harmonic minor"],
    [
        "1P 2m 3m 3M 5d 6m 7m",
        "altered",
        "super locrian",
        "diminished whole tone",
        "pomeroy"
    ],
    ["1P 2M 3m 4P 5d 6m 7m", "locrian #2", "half-diminished"],
    [
        "1P 2M 3M 4P 5P 6m 7m",
        "melodic minor fifth mode",
        "hindu",
        "mixolydian b6M"
    ],
    ["1P 2M 3M 4A 5P 6M 7m", "lydian dominant", "lydian b7"],
    ["1P 2M 3M 4A 5P 6M 7M", "lydian"],
    ["1P 2M 3M 4A 5A 6M 7M", "lydian augmented"],
    ["1P 2m 3m 4P 5P 6M 7m", "melodic minor second mode"],
    ["1P 2M 3m 4P 5P 6M 7M", "melodic minor"],
    ["1P 2m 3m 4P 5d 6m 7m", "locrian"],
    ["1P 2A 3M 4P 5P 5A 7M", "augmented heptatonic"],
    ["1P 2M 3m 4A 5P 6M 7m", "dorian #4"],
    ["1P 2M 3m 4A 5P 6M 7M", "lydian diminished"],
    ["1P 2m 3m 4P 5P 6m 7m", "phrygian"],
    ["1P 2M 3M 4A 5A 7m 7M", "leading whole tone"],
    ["1P 2M 3M 4A 5P 6m 7m", "lydian minor"],
    ["1P 2m 3M 4P 5P 6m 7m", "phrygian dominant", "spanish", "phrygian major"],
    ["1P 2m 3m 4P 5P 6m 7M", "balinese"],
    ["1P 2m 3m 4P 5P 6M 7M", "neopolitan major", "dorian b2"],
    ["1P 2M 3m 4P 5P 6m 7m", "aeolian", "minor"],
    ["1P 2M 3m 5d 5P 6M 7m", "romanian minor"],
    ["1P 2M 3M 4P 5P 6m 7M", "harmonic major"],
    ["1P 2m 3M 4P 5P 6m 7M", "double harmonic major", "gypsy"],
    ["1P 2M 3m 4P 5P 6M 7m", "dorian"],
    ["1P 2M 3m 4A 5P 6m 7M", "hungarian minor"],
    ["1P 2A 3M 4A 5P 6M 7m", "hungarian major"],
    ["1P 2m 3M 4P 5d 6M 7m", "oriental"],
    ["1P 2m 3m 3M 4A 5P 7m", "flamenco"],
    ["1P 2m 3m 4A 5P 6m 7M", "todi raga"],
    ["1P 2M 3M 4P 5P 6M 7m", "mixolydian", "dominant"],
    ["1P 2m 3M 4P 5d 6m 7M", "persian"],
    ["1P 2M 3M 4P 5P 6M 7M", "major", "ionian"],
    ["1P 2m 3M 5d 6m 7m 7M", "enigmatic"],
    ["1P 2M 3M 4P 5A 6M 7M", "ionian augmented"],
    ["1P 2A 3M 4A 5P 6M 7M", "lydian #9"],
    // 8-note scales
    ["1P 2m 3M 4P 4A 5P 6m 7M", "purvi raga"],
    ["1P 2m 3m 3M 4P 5P 6m 7m", "spanish heptatonic"],
    ["1P 2M 3M 4P 5P 6M 7m 7M", "bebop"],
    ["1P 2M 3m 3M 4P 5P 6M 7m", "bebop minor"],
    ["1P 2M 3M 4P 5P 5A 6M 7M", "bebop major"],
    ["1P 2m 3m 4P 5d 5P 6m 7m", "bebop locrian"],
    ["1P 2M 3m 4P 5P 6m 7m 7M", "minor bebop"],
    ["1P 2M 3m 4P 5d 6m 6M 7M", "diminished", "whole-half diminished"],
    ["1P 2M 3M 4P 5d 5P 6M 7M", "ichikosucho"],
    ["1P 2M 3m 4P 5P 6m 6M 7M", "minor six diminished"],
    ["1P 2m 3m 3M 4A 5P 6M 7m", "half-whole diminished", "dominant diminished"],
    ["1P 3m 3M 4P 5P 6M 7m 7M", "kafi raga"],
    // 9-note scales
    ["1P 2M 3m 3M 4P 5d 5P 6M 7m", "composite blues"],
    // 12-note scales
    ["1P 2m 2M 3m 3M 4P 4A 5P 6m 6M 7m 7M", "chromatic"]
];

const NoScaleType = {};
Object.assign(NoScaleType, EmptyPcset);
Object.assign(NoScaleType, { intervals: [], aliases: [] });

const scales = SCALES.map(dataToScaleType);
const index = scales.reduce((index, scale) => {
    index[scale.name] = scale;
    index[scale.setNum] = scale;
    index[scale.chroma] = scale;
    scale.aliases.forEach(alias => {
        index[alias] = scale;
    });
    return index;
}, {});
const ks = Object.keys(index);
/**
 * Given a scale name or chroma, return the scale properties
 * @param {string} type - scale name or pitch class set chroma
 * @example
 * import { scale } from 'tonaljs/scale-dictionary'
 * scale('major')
 */
function scaleType(type) {
    return index[type] || NoScaleType;
}
/**
 * Return a list of all scale types
 */
function entries() {
    return scales.slice();
}
function keys() {
    return ks.slice();
}
function dataToScaleType([ivls, name, ...aliases]) {
    const intervals = ivls.split(" ");
    const ret = {}
    Object.assign(ret, pcset(intervals));
    Object.assign(ret, { name, intervals, aliases });
    return ret;
}

export { NoScaleType, entries, keys, scaleType };
//# sourceMappingURL=index.esnext.js.map
