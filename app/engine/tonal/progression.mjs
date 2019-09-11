import { tokenize } from './chord.mjs';
import { romanNumeral } from './roman-numeral.mjs';
import { transpose, interval, distance } from './tonal.mjs';

/**
 * Given a tonic and a chord list expressed with roman numeral notation
 * returns the progression expressed with leadsheet chords symbols notation
 * @example
 * fromRomanNumerals("C", ["I", "IIm7", "V7"]);
 * // => ["C", "Dm7", "G7"]
 */
function fromRomanNumerals(tonic, chords) {
    const romanNumerals = chords.map(romanNumeral);
    return romanNumerals.map(rn => transpose(tonic, interval(rn)) + rn.chordType);
}
/**
 * Given a tonic and a chord list with leadsheet symbols notation,
 * return the chord list with roman numeral notation
 * @example
 * toRomanNumerals("C", ["CMaj7", "Dm7", "G7"]);
 * // => ["IMaj7", "IIm7", "V7"]
 */
function toRomanNumerals(tonic, chords) {
    return chords.map(chord => {
        const [note, chordType] = tokenize(chord);
        const intervalName = distance(tonic, note);
        const roman = romanNumeral(interval(intervalName));
        return roman.name + chordType;
    });
}

export { fromRomanNumerals, toRomanNumerals };
//# sourceMappingURL=index.esnext.js.map
