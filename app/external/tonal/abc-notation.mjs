import { note, transpose as transpose$1 } from './tonal.mjs';

const fillStr = (character, times) => Array(times + 1).join(character);
const REGEX = /^(_{1,}|=|\^{1,}|)([abcdefgABCDEFG])([,']*)$/;
function tokenize(str) {
    const m = REGEX.exec(str);
    if (!m) {
        return ["", "", ""];
    }
    return [m[1], m[2], m[3]];
}
/**
 * Convert a (string) note in ABC notation into a (string) note in scientific notation
 *
 * @example
 * abcToScientificNotation("c") // => "C5"
 */
function abcToScientificNotation(str) {
    const [acc, letter, oct] = tokenize(str);
    if (letter === "") {
        return "";
    }
    let o = 4;
    for (let i = 0; i < oct.length; i++) {
        o += oct.charAt(i) === "," ? -1 : 1;
    }
    const a = acc[0] === "_"
        ? acc.replace(/_/g, "b")
        : acc[0] === "^"
            ? acc.replace(/\^/g, "#")
            : "";
    return letter.charCodeAt(0) > 96
        ? letter.toUpperCase() + a + (o + 1)
        : letter + a + o;
}
/**
 * Convert a (string) note in scientific notation into a (string) note in ABC notation
 *
 * @example
 * scientificToAbcNotation("C#4") // => "^C"
 */
function scientificToAbcNotation(str) {
    const n = note(str);
    if (n.empty || !n.oct) {
        return "";
    }
    const { letter, acc, oct } = n;
    const a = acc[0] === "b" ? acc.replace(/b/g, "_") : acc.replace(/#/g, "^");
    const l = oct > 4 ? letter.toLowerCase() : letter;
    const o = oct === 5 ? "" : oct > 4 ? fillStr("'", oct - 5) : fillStr(",", 4 - oct);
    return a + l + o;
}
function transpose(note, interval) {
    return scientificToAbcNotation(transpose$1(abcToScientificNotation(note), interval));
}

export { abcToScientificNotation, scientificToAbcNotation, tokenize, transpose };
//# sourceMappingURL=index.esnext.js.map
