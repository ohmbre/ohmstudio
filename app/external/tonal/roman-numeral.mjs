import { isPitch, altToAcc, isNamed, accToAlt } from './tonal.mjs';

const NoRomanNumeral = { empty: true, name: "", chordType: "" };
const cache = {};
/**
 * Get properties of a roman numeral string
 *
 * @function
 * @param {string} - the roman numeral string (can have type, like: Imaj7)
 * @return {Object} - the roman numeral properties
 * @param {string} name - the roman numeral (tonic)
 * @param {string} type - the chord type
 * @param {string} num - the number (1 = I, 2 = II...)
 * @param {boolean} major - major or not
 *
 * @example
 * props("VIIb5") // => { name: "VII", type: "b5", num: 7, major: true }
 */
function romanNumeral(src) {
    return typeof src === "string"
        ? cache[src] || (cache[src] = parse(src))
        : typeof src === "number"
            ? romanNumeral(NAMES[src] || "")
            : isPitch(src)
                ? fromPitch(src)
                : isNamed(src)
                    ? romanNumeral(src.name)
                    : NoRomanNumeral;
}
/**
 * Get roman numeral names
 *
 * @function
 * @param {boolean} [isMajor=true]
 * @return {Array<String>}
 *
 * @example
 * names() // => ["I", "II", "III", "IV", "V", "VI", "VII"]
 */
function names(major = true) {
    return (major ? NAMES : NAMES_MINOR).slice();
}
function fromPitch(pitch) {
    return romanNumeral(altToAcc(pitch.alt) + NAMES[pitch.step]);
}
const REGEX = /^(#{1,}|b{1,}|x{1,}|)(IV|I{1,3}|VI{0,2}|iv|i{1,3}|vi{0,2})([^IViv]*)$/;
function tokenize(str) {
    return (REGEX.exec(str) || ["", "", "", ""]);
}
const ROMANS = "I II III IV V VI VII";
const NAMES = ROMANS.split(" ");
const NAMES_MINOR = ROMANS.toLowerCase().split(" ");
function parse(src) {
    const [name, acc, roman, chordType] = tokenize(src);
    if (!roman) {
        return NoRomanNumeral;
    }
    const alt = accToAlt(acc);
    const upperRoman = roman.toUpperCase();
    const major = roman === upperRoman;
    const step = NAMES.indexOf(upperRoman);
    return {
        empty: false,
        name,
        roman,
        acc,
        chordType,
        alt,
        step,
        major,
        oct: 0,
        dir: 1
    };
}

export { names, romanNumeral, tokenize };
//# sourceMappingURL=index.esnext.js.map
