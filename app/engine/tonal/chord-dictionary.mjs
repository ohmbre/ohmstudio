import { pcset, EmptyPcset } from './pcset.mjs';

/**
 * @private
 * Chord List
 * Source: https://en.wikibooks.org/wiki/Music_Theory/Complete_List_of_Chord_Patterns
 * Format: ["intervals", "full name", "abrv1 abrv2"]
 */
const CHORDS = [
    // ==Major==
    ["1P 3M 5P", "major", "M "],
    ["1P 3M 5P 7M", "major seventh", "maj7 Δ ma7 M7 Maj7"],
    ["1P 3M 5P 7M 9M", "major ninth", "maj9 Δ9"],
    ["1P 3M 5P 7M 9M 13M", "major thirteenth", "maj13 Maj13"],
    ["1P 3M 5P 6M", "sixth", "6 add6 add13 M6"],
    ["1P 3M 5P 6M 9M", "sixth/ninth", "6/9 69"],
    ["1P 3M 5P 7M 11A", "lydian", "maj#4 Δ#4 Δ#11"],
    ["1P 3M 6m 7M", "major seventh b6", "M7b6"],
    // ==Minor==
    // '''Normal'''
    ["1P 3m 5P", "minor", "m min -"],
    ["1P 3m 5P 7m", "minor seventh", "m7 min7 mi7 -7"],
    ["1P 3m 5P 7M", "minor/major seventh", "m/ma7 m/maj7 mM7 m/M7 -Δ7 mΔ"],
    ["1P 3m 5P 6M", "minor sixth", "m6"],
    ["1P 3m 5P 7m 9M", "minor ninth", "m9"],
    ["1P 3m 5P 7m 9M 11P", "minor eleventh", "m11"],
    ["1P 3m 5P 7m 9M 13M", "minor thirteenth", "m13"],
    // '''Diminished'''
    ["1P 3m 5d", "diminished", "dim ° o"],
    ["1P 3m 5d 7d", "diminished seventh", "dim7 °7 o7"],
    ["1P 3m 5d 7m", "half-diminished", "m7b5 ø"],
    // ==Dominant/Seventh==
    // '''Normal'''
    ["1P 3M 5P 7m", "dominant seventh", "7 dom"],
    ["1P 3M 5P 7m 9M", "dominant ninth", "9"],
    ["1P 3M 5P 7m 9M 13M", "dominant thirteenth", "13"],
    ["1P 3M 5P 7m 11A", "lydian dominant seventh", "7#11 7#4"],
    // '''Altered'''
    ["1P 3M 5P 7m 9m", "dominant b9", "7b9"],
    ["1P 3M 5P 7m 9A", "dominant #9", "7#9"],
    ["1P 3M 7m 9m", "altered", "alt7"],
    // '''Suspended'''
    ["1P 4P 5P", "suspended 4th", "sus4"],
    ["1P 2M 5P", "suspended 2nd", "sus2"],
    ["1P 4P 5P 7m", "suspended 4th seventh", "7sus4"],
    ["1P 5P 7m 9M 11P", "eleventh", "11 sus Bb/C for C11"],
    ["1P 4P 5P 7m 9m", "suspended 4th b9", "b9sus phryg"],
    // ==Other==
    ["1P 5P", "fifth", "5"],
    ["1P 3M 5A", "augmented", "aug + +5"],
    ["1P 3M 5A 7M", "augmented seventh", "maj7#5 maj7+5"],
    ["1P 3M 5P 7M 9M 11A", "major #11 (lydian)", "maj9#11 Δ9#11"],
    ["1P 3M 5P 7m 9A", "dominant #9", "7#9"],
    // ==Legacy==
    ["1P 2M 4P 5P", "", "sus24 sus4add9"],
    ["1P 3M 13m", "", "Mb6"],
    ["1P 3M 5A 7M 9M", "", "maj9#5 Maj9#5"],
    ["1P 3M 5A 7m", "", "7#5 +7 7aug aug7"],
    ["1P 3M 5A 7m 9A", "", "7#5#9 7alt 7#5#9_ 7#9b13_"],
    ["1P 3M 5A 7m 9M", "", "9#5 9+"],
    ["1P 3M 5A 7m 9M 11A", "", "9#5#11"],
    ["1P 3M 5A 7m 9m", "", "7#5b9"],
    ["1P 3M 5A 7m 9m 11A", "", "7#5b9#11"],
    ["1P 3M 5A 9A", "", "+add#9"],
    ["1P 3M 5A 9M", "", "M#5add9 +add9"],
    ["1P 3M 5P 6M 11A", "", "M6#11 M6b5 6#11 6b5"],
    ["1P 3M 5P 6M 7M 9M", "", "M7add13"],
    ["1P 3M 5P 6M 9M 11A", "", "69#11"],
    ["1P 3M 5P 6m 7m", "", "7b6"],
    ["1P 3M 5P 7M 9A 11A", "", "maj7#9#11"],
    ["1P 3M 5P 7M 9M 11A 13M", "", "M13#11 maj13#11 M13+4 M13#4"],
    ["1P 3M 5P 7M 9m", "", "M7b9"],
    ["1P 3M 5P 7m 11A 13m", "", "7#11b13 7b5b13"],
    ["1P 3M 5P 7m 13M", "", "7add6 67 7add13"],
    ["1P 3M 5P 7m 9A 11A", "", "7#9#11 7b5#9"],
    ["1P 3M 5P 7m 9A 11A 13M", "", "13#9#11"],
    ["1P 3M 5P 7m 9A 11A 13m", "", "7#9#11b13"],
    ["1P 3M 5P 7m 9A 13M", "", "13#9 13#9_"],
    ["1P 3M 5P 7m 9A 13m", "", "7#9b13"],
    ["1P 3M 5P 7m 9M 11A", "", "9#11 9+4 9#4 9#11_ 9#4_"],
    ["1P 3M 5P 7m 9M 11A 13M", "", "13#11 13+4 13#4"],
    ["1P 3M 5P 7m 9M 11A 13m", "", "9#11b13 9b5b13"],
    ["1P 3M 5P 7m 9m 11A", "", "7b9#11 7b5b9"],
    ["1P 3M 5P 7m 9m 11A 13M", "", "13b9#11"],
    ["1P 3M 5P 7m 9m 11A 13m", "", "7b9b13#11 7b9#11b13 7b5b9b13"],
    ["1P 3M 5P 7m 9m 13M", "", "13b9"],
    ["1P 3M 5P 7m 9m 13m", "", "7b9b13"],
    ["1P 3M 5P 7m 9m 9A", "", "7b9#9"],
    ["1P 3M 5P 9M", "", "Madd9 2 add9 add2"],
    ["1P 3M 5P 9m", "", "Maddb9"],
    ["1P 3M 5d", "", "Mb5"],
    ["1P 3M 5d 6M 7m 9M", "", "13b5"],
    ["1P 3M 5d 7M", "", "M7b5"],
    ["1P 3M 5d 7M 9M", "", "M9b5"],
    ["1P 3M 5d 7m", "", "7b5"],
    ["1P 3M 5d 7m 9M", "", "9b5"],
    ["1P 3M 7m", "", "7no5"],
    ["1P 3M 7m 13m", "", "7b13"],
    ["1P 3M 7m 9M", "", "9no5"],
    ["1P 3M 7m 9M 13M", "", "13no5"],
    ["1P 3M 7m 9M 13m", "", "9b13"],
    ["1P 3m 4P 5P", "", "madd4"],
    ["1P 3m 5A", "", "m#5 m+ mb6"],
    ["1P 3m 5P 6M 9M", "", "m69 _69"],
    ["1P 3m 5P 6m 7M", "", "mMaj7b6"],
    ["1P 3m 5P 6m 7M 9M", "", "mMaj9b6"],
    ["1P 3m 5P 7M 9M", "", "mMaj9 -Maj9"],
    ["1P 3m 5P 7m 11P", "", "m7add11 m7add4"],
    ["1P 3m 5P 9M", "", "madd9"],
    ["1P 3m 5d 6M 7M", "", "o7M7"],
    ["1P 3m 5d 7M", "", "oM7"],
    ["1P 3m 5d 7m", "", "m7b5 half-diminished h7 _7b5"],
    ["1P 3m 6m 7M", "", "mb6M7"],
    ["1P 3m 6m 7m", "", "m7#5"],
    ["1P 3m 6m 7m 9M", "", "m9#5"],
    ["1P 3m 6m 7m 9M 11P", "", "m11A"],
    ["1P 3m 6m 9m", "", "mb6b9"],
    ["1P 3m 7m 12d 2M", "", "m9b5 h9 -9b5"],
    ["1P 3m 7m 12d 2M 4P", "", "m11b5 h11 _11b5"],
    ["1P 4P 5A 7M", "", "M7#5sus4"],
    ["1P 4P 5A 7M 9M", "", "M9#5sus4"],
    ["1P 4P 5A 7m", "", "7#5sus4"],
    ["1P 4P 5P 7M", "", "M7sus4"],
    ["1P 4P 5P 7M 9M", "", "M9sus4"],
    ["1P 4P 5P 7m 9M", "", "9sus4 9sus"],
    ["1P 4P 5P 7m 9M 13M", "", "13sus4 13sus"],
    ["1P 4P 5P 7m 9m 13m", "", "7sus4b9b13 7b9b13sus4"],
    ["1P 4P 7m 10m", "", "4 quartal"],
    ["1P 5P 7m 9m 11P", "", "11b9"]
];

const NoChordType = {
    ...EmptyPcset,
    name: "",
    quality: "Unknown",
    intervals: [],
    aliases: []
};
const chords = CHORDS.map(dataToChordType);
chords.sort((a, b) => a.setNum - b.setNum);
const index = chords.reduce((index, chord) => {
    if (chord.name) {
        index[chord.name] = chord;
    }
    index[chord.setNum] = chord;
    index[chord.chroma] = chord;
    chord.aliases.forEach(alias => {
        index[alias] = chord;
    });
    return index;
}, {});
/**
 * Given a chord name or chroma, return the chord properties
 * @param {string} source - chord name or pitch class set chroma
 * @example
 * import { chord } from 'tonaljs/chord-dictionary'
 * chord('major')
 */
function chordType(type) {
    return index[type] || NoChordType;
}
/**
 * Return a list of all chord types
 */
function entries() {
    return chords.slice();
}
function getQuality(intervals) {
    const has = (interval) => intervals.indexOf(interval) !== -1;
    return has("5A")
        ? "Augmented"
        : has("3M")
            ? "Major"
            : has("5d")
                ? "Diminished"
                : has("3m")
                    ? "Minor"
                    : "Unknown";
}
function dataToChordType([ivls, name, abbrvs]) {
    const intervals = ivls.split(" ");
    const aliases = abbrvs.split(" ");
    const quality = getQuality(intervals);
    const set = pcset(intervals);
    return { ...set, name, quality, intervals, aliases };
}

export { chordType, entries };
//# sourceMappingURL=index.esnext.js.map
