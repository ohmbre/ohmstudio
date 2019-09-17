import { sortedUniqNoteNames, rotate } from './array.mjs';
import { entries } from './chord-dictionary.mjs';
import { isSubsetOf, isSupersetOf, modes } from './pcset.mjs';
import { scaleType, entries as entries$1 } from './scale-dictionary.mjs';
import { note, transpose } from './tonal.mjs';

const NoScale = {
    empty: true,
    name: "",
    type: "",
    tonic: null,
    setNum: NaN,
    chroma: "",
    normalized: "",
    aliases: [],
    notes: [],
    intervals: []
};
/**
 * Given a string with a scale name and (optionally) a tonic, split
 * that components.
 *
 * It retuns an array with the form [ name, tonic ] where tonic can be a
 * note name or null and name can be any arbitrary string
 * (this function doesn"t check if that scale name exists)
 *
 * @function
 * @param {string} name - the scale name
 * @return {Array} an array [tonic, name]
 * @example
 * tokenize("C mixolydean") // => ["C", "mixolydean"]
 * tokenize("anything is valid") // => ["", "anything is valid"]
 * tokenize() // => ["", ""]
 */
function tokenize(name) {
    if (typeof name !== "string") {
        return ["", ""];
    }
    const i = name.indexOf(" ");
    const tonic = note(name.substring(0, i));
    if (tonic.empty) {
        const n = note(name);
        return n.empty ? ["", name] : [n.name, ""];
    }
    const type = name.substring(tonic.name.length + 1);
    return [tonic.name, type.length ? type : ""];
}
/**
 * Get a Scale from a scale name.
 */
function scale(src) {
    const tokens = Array.isArray(src) ? src : tokenize(src);
    const tonic = note(tokens[0]).name;
    const st = scaleType(tokens[1]);
    if (st.empty) {
        return NoScale;
    }
    const type = st.name;
    const notes = tonic
        ? st.intervals.map(i => transpose(tonic, i))
        : [];
    const name = tonic ? tonic + " " + type : type;
    const ret = { name, type, tonic, notes };
    Object.assign(ret, st);
    return ret;
}
/**
 * Get all chords that fits a given scale
 *
 * @function
 * @param {string} name - the scale name
 * @return {Array<string>} - the chord names
 *
 * @example
 * scaleChords("pentatonic") // => ["5", "64", "M", "M6", "Madd9", "Msus2"]
 */
function scaleChords(name) {
    const s = scale(name);
    const inScale = isSubsetOf(s.chroma);
    return entries()
        .filter(chord => inScale(chord.chroma))
        .map(chord => chord.aliases[0]);
}
/**
 * Get all scales names that are a superset of the given one
 * (has the same notes and at least one more)
 *
 * @function
 * @param {string} name
 * @return {Array} a list of scale names
 * @example
 * extended("major") // => ["bebop", "bebop dominant", "bebop major", "chromatic", "ichikosucho"]
 */
function extended(name) {
    const s = scale(name);
    const isSuperset = isSupersetOf(s.chroma);
    return entries$1()
        .filter(scale => isSuperset(scale.chroma))
        .map(scale => scale.name);
}
/**
 * Find all scales names that are a subset of the given one
 * (has less notes but all from the given scale)
 *
 * @function
 * @param {string} name
 * @return {Array} a list of scale names
 *
 * @example
 * reduced("major") // => ["ionian pentatonic", "major pentatonic", "ritusen"]
 */
function reduced(name) {
    const isSubset = isSubsetOf(scale(name).chroma);
    return entries$1()
        .filter(scale => isSubset(scale.chroma))
        .map(scale => scale.name);
}
/**
 * Given an array of notes, return the scale: a pitch class set starting from
 * the first note of the array
 *
 * @function
 * @param {string[]} notes
 * @return {string[]} pitch classes with same tonic
 * @example
 * scaleNotes(['C4', 'c3', 'C5', 'C4', 'c4']) // => ["C"]
 * scaleNotes(['D4', 'c#5', 'A5', 'F#6']) // => ["D", "F#", "A", "C#"]
 */
function scaleNotes(notes) {
    const pcset = notes.map(n => note(n).pc).filter(x => x);
    const tonic = pcset[0];
    const scale = sortedUniqNoteNames(pcset);
    return rotate(scale.indexOf(tonic), scale);
}
/**
 * Find mode names of a scale
 *
 * @function
 * @param {string} name - scale name
 * @example
 * modeNames("C pentatonic") // => [
 *   ["C", "major pentatonic"],
 *   ["D", "egyptian"],
 *   ["E", "malkos raga"],
 *   ["G", "ritusen"],
 *   ["A", "minor pentatonic"]
 * ]
 */
function modeNames(name) {
    const s = scale(name);
    if (s.empty) {
        return [];
    }
    const tonics = s.tonic ? s.notes : s.intervals;
    return modes(s.chroma)
        .map((chroma, i) => {
        const modeName = scale(chroma).name;
        return modeName ? [tonics[i], modeName] : ["", ""];
    })
        .filter(x => x[0]);
}

export { extended, modeNames, reduced, scale, scaleChords, scaleNotes, tokenize };
//# sourceMappingURL=index.esnext.js.map
