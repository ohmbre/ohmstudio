import { EmptyPcset, pcset } from './pcset.mjs';

// SCALES
// Format: ["intervals", "name", "alias1", "alias2", ...]
const SCALES = [
    ["1P 2M 3M 4P 5P 6M 7M", "major"],
    ["1P 2M 3m 4P 5P 6m 7m", "minor"],
    ["1P 2M 3M 5P 6M", "pentatonic"],
    ["1P 3m 4P 5d 5P 7m", "blues"],
    ["1P 2M 3m 3M 5P 6M", "major blues"],
    ["1P 2M 3m 4P 5P 7M", "hexatonic"],
    ["1P 2m 3m 4P 5d 6m 7m", "locrian"],
    ["1P 2m 3m 4P 5P 6m 7m", "phrygian"],
    ["1P 2M 3M 4A 5P 6M 7M", "lydian"],
    ["1P 2M 3m 4P 5P 6M 7m", "dorian"],
    ["1P 2M 3m 4P 5P 6M 7M", "melodic"],
    ["1P 3M 4P 5P 7m", "indian"],
    ["1P 2M 4P 5P 6M", "ritusen"],
    ["1P 2M 4P 5P 7m", "egyptian"],
    ["1P 2m 3m 5P 6m", "pelog"],
    ["1P 2m 4P 5P 6m", "kumoijoshi"],
    ["1P 2M 3m 5P 6m", "hirajoshi"],
    ["1P 2m 4P 5d 7m", "iwato"],
    ["1P 2m 4P 5P 7m", "in-sen"],
    ["1P 3M 4A 5P 7M", "chinese"],
    ["1P 3m 4P 6m 7m", "malkos raga"],
    ["1P 2M 3m 5P 6M", "kumoi"],
    ["1P 2m 3M 5P 6M", "scriabin"],
    ["1P 2M 4P 5P 6M 7m", "piongio"],
    ["1P 2M 3M 4A 6M 7m", "prometheus"],
    ["1P 2M 3M 4A 5A 7m", "whole tone"],
    ["1P 2M 3M 4P 5d 6m 7m", "arabian"],
    ["1P 2M 3M 4P 5P 6m 7m", "hindu"],
    ["1P 2m 3M 4P 5P 6m 7m", "spanish"],
    ["1P 2m 3m 4P 5P 6m 7M", "balinese"],
    ["1P 2M 3m 5d 5P 6M 7m", "romanian"],
    ["1P 2m 3M 4P 5P 6m 7M", "gypsy"],
    ["1P 2M 3m 4A 5P 6m 7M", "hungarian"],
    ["1P 2m 3m 3M 4A 5P 7m", "flamenco"],
    ["1P 2m 3M 4P 5d 6m 7M", "persian"],
    ["1P 2m 3M 5d 6m 7m 7M", "enigmatic"],
    ["1P 2M 3M 4P 5P 6M 7m 7M", "bebop"],
    ["1P 2M 3m 3M 4P 5d 5P 6M 7m", "composite blues"],
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
