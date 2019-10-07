import { chromaToIntervals, EmptyPcset } from './pcset.mjs';

const DATA = [
    [0, 2773, 0, "ionian", "", "Maj7", "major"],
    [1, 2902, 2, "dorian", "m", "m7"],
    [2, 3418, 4, "phrygian", "m", "m7"],
    [3, 2741, -1, "lydian", "", "Maj7"],
    [4, 2774, 1, "mixolydian", "", "7"],
    [5, 2906, 3, "aeolian", "m", "m7", "minor"],
    [6, 3434, 5, "locrian", "dim", "m7b5"]
];

const NoMode = {}
Object.assign(NoMode, EmptyPcset)
Object.assign(NoMode, {
    name: "",
    alt: 0,
    modeNum: NaN,
    triad: "",
    seventh: "",
    aliases: []
});
const all = DATA.map(toMode);
const index = {};
all.forEach(mode => {
    index[mode.name] = mode;
    mode.aliases.forEach(alias => {
        index[alias] = mode;
    });
});
/**
 * Get a Mode by it's name
 *
 * @example
 * mode('dorian')
 * // =>
 * // {
 * //   intervals: [ '1P', '2M', '3m', '4P', '5P', '6M', '7m' ],
 * //   modeNum: 1,
 * //   chroma: '101101010110',
 * //   normalized: '101101010110',
 * //   name: 'dorian',
 * //   setNum: 2902,
 * //   alt: 2,
 * //   triad: 'm',
 * //   seventh: 'm7',
 * //   aliases: []
 * // }
 */
function mode(name) {
    return typeof name === "string"
        ? index[name.toLowerCase()] || NoMode
        : name && name.name
            ? mode(name.name)
            : NoMode;
}
/**
 * Get a list of all know modes
 */
function entries() {
    return all.slice();
}
function toMode(mode) {
    const [modeNum, setNum, alt, name, triad, seventh, alias] = mode;
    const aliases = alias ? [alias] : [];
    const chroma = Number(setNum).toString(2);
    const intervals = chromaToIntervals(chroma);
    return {
        empty: false,
        intervals,
        modeNum,
        chroma,
        normalized: chroma,
        name,
        setNum,
        alt,
        triad,
        seventh,
        aliases
    };
}

export { entries, mode };
//# sourceMappingURL=index.esnext.js.map
