function isNamed(src) {
    return typeof src === "object" && typeof src.name === "string";
}

function isPitch(pitch) {
    return (typeof pitch === "object" &&
        typeof pitch.step === "number" &&
        typeof pitch.alt === "number");
}
// The nuuber of fifths of [C, D, E, F, G, A, B]
const FIFTHS = [0, 2, 4, -1, 1, 3, 5];
// The number of octaves it span each step
const STEPS_TO_OCTS = FIFTHS.map((fifths) => Math.floor((fifths * 7) / 12));
function encode(pitch) {
    const { step, alt, oct, dir = 1 } = pitch;
    const f = FIFTHS[step] + 7 * alt;
    if (oct === undefined) {
        return [dir * f];
    }
    const o = oct - STEPS_TO_OCTS[step] - 4 * alt;
    return [dir * f, dir * o];
}
// We need to get the steps from fifths
// Fifths for CDEFGAB are [ 0, 2, 4, -1, 1, 3, 5 ]
// We add 1 to fifths to avoid negative numbers, so:
// for ["F", "C", "G", "D", "A", "E", "B"] we have:
const FIFTHS_TO_STEPS = [3, 0, 4, 1, 5, 2, 6];
function decode(coord) {
    const [f, o, dir] = coord;
    const step = FIFTHS_TO_STEPS[unaltered(f)];
    const alt = Math.floor((f + 1) / 7);
    if (o === undefined) {
        return { step, alt, dir };
    }
    const oct = o + 4 * alt + STEPS_TO_OCTS[step];
    return { step, alt, oct, dir };
}
// Return the number of fifths as if it were unaltered
function unaltered(f) {
    const i = (f + 1) % 7;
    return i < 0 ? 7 + i : i;
}

const NoNote = { empty: true, name: "", pc: "", acc: "" };
const cache = {};
const fillStr = (s, n) => Array(n + 1).join(s);
const stepToLetter = (step) => "CDEFGAB".charAt(step);
const altToAcc = (alt) => alt < 0 ? fillStr("b", -alt) : fillStr("#", alt);
const accToAlt = (acc) => acc[0] === "b" ? -acc.length : acc.length;
/**
 * Given a note literal (a note name or a note object), returns the Note object
 * @example
 * note('Bb4') // => { name: "Bb4", midi: 70, chroma: 10, ... }
 */
function note(src) {
    return typeof src === "string"
        ? cache[src] || (cache[src] = parse(src))
        : isPitch(src)
            ? note(pitchName(src))
            : isNamed(src)
                ? note(src.name)
                : NoNote;
}
const REGEX = /^([a-gA-G]?)(#{1,}|b{1,}|x{1,}|)(-?\d*)\s*(.*)$/;
/**
 * @private
 */
function tokenize(str) {
    const m = REGEX.exec(str);
    return [m[1].toUpperCase(), m[2].replace(/x/g, "##"), m[3], m[4]];
}
/**
 * @private
 */
function coordToNote(noteCoord) {
    return note(decode(noteCoord));
}
const SEMI = [0, 2, 4, 5, 7, 9, 11];
function parse(noteName) {
    const tokens = tokenize(noteName);
    if (tokens[0] === "" || tokens[3] !== "") {
        return NoNote;
    }
    const letter = tokens[0];
    const acc = tokens[1];
    const octStr = tokens[2];
    const step = (letter.charCodeAt(0) + 3) % 7;
    const alt = accToAlt(acc);
    const oct = octStr.length ? +octStr : undefined;
    const coord = encode({ step, alt, oct });
    const name = letter + acc + octStr;
    const pc = letter + acc;
    const chroma = (SEMI[step] + alt + 120) % 12;
    const o = oct === undefined ? -100 : oct;
    const height = SEMI[step] + alt + 12 * (o + 1);
    const midi = height >= 0 && height <= 127 ? height : null;
    const freq = oct === undefined ? null : Math.pow(2, (height - 69) / 12) * 440;
    return {
        empty: false,
        acc,
        alt,
        chroma,
        coord,
        freq,
        height,
        letter,
        midi,
        name,
        oct,
        pc,
        step
    };
}
function pitchName(props) {
    const { step, alt, oct } = props;
    const letter = stepToLetter(step);
    if (!letter) {
        return "";
    }
    const pc = letter + altToAcc(alt);
    return oct || oct === 0 ? pc + oct : pc;
}

const NoInterval = { empty: true, name: "", acc: "" };
// shorthand tonal notation (with quality after number)
const INTERVAL_TONAL_REGEX = "([-+]?\\d+)(d{1,4}|m|M|P|A{1,4})";
// standard shorthand notation (with quality before number)
const INTERVAL_SHORTHAND_REGEX = "(AA|A|P|M|m|d|dd)([-+]?\\d+)";
const REGEX$1 = new RegExp("^" + INTERVAL_TONAL_REGEX + "|" + INTERVAL_SHORTHAND_REGEX + "$");
/**
 * @private
 */
function tokenize$1(str) {
    const m = REGEX$1.exec(`${str}`);
    if (m === null) {
        return ["", ""];
    }
    return m[1] ? [m[1], m[2]] : [m[4], m[3]];
}
const cache$1 = {};
/**
 * Get interval properties. It returns an object with:
 *
 * - name: the interval name
 * - num: the interval number
 * - type: 'perfectable' or 'majorable'
 * - q: the interval quality (d, m, M, A)
 * - dir: interval direction (1 ascending, -1 descending)
 * - simple: the simplified number
 * - semitones: the size in semitones
 * - chroma: the interval chroma
 *
 * @param {string} interval - the interval name
 * @return {Object} the interval properties
 *
 * @example
 * import { interval } from '@tonaljs/tonal'
 * interval('P5').semitones // => 7
 * interval('m3').type // => 'majorable'
 */
function interval(src) {
    return typeof src === "string"
        ? cache$1[src] || (cache$1[src] = parse$1(src))
        : isPitch(src)
            ? interval(pitchName$1(src))
            : isNamed(src)
                ? interval(src.name)
                : NoInterval;
}
const SIZES = [0, 2, 4, 5, 7, 9, 11];
const TYPES = "PMMPPMM";
function parse$1(str) {
    const tokens = tokenize$1(str);
    if (tokens[0] === "") {
        return NoInterval;
    }
    const num = +tokens[0];
    const q = tokens[1];
    const step = (Math.abs(num) - 1) % 7;
    const t = TYPES[step];
    if (t === "M" && q === "P") {
        return NoInterval;
    }
    const type = t === "M" ? "majorable" : "perfectable";
    const name = "" + num + q;
    const dir = num < 0 ? -1 : 1;
    const simple = num === 8 || num === -8 ? num : dir * (step + 1);
    const alt = qToAlt(type, q);
    const oct = Math.floor((Math.abs(num) - 1) / 7);
    const semitones = dir * (SIZES[step] + alt + 12 * oct);
    const chroma = (((dir * (SIZES[step] + alt)) % 12) + 12) % 12;
    const coord = encode({ step, alt, oct, dir });
    return {
        empty: false,
        name,
        num,
        q,
        step,
        alt,
        dir,
        type,
        simple,
        semitones,
        chroma,
        coord,
        oct
    };
}
/**
 * @private
 */
function coordToInterval(coord) {
    const [f, o = 0] = coord;
    const isDescending = f * 7 + o * 12 < 0;
    const ivl = isDescending ? [-f, -o, -1] : [f, o, 1];
    return interval(decode(ivl));
}
function qToAlt(type, q) {
    return (q === "M" && type === "majorable") ||
        (q === "P" && type === "perfectable")
        ? 0
        : q === "m" && type === "majorable"
            ? -1
            : /^A+$/.test(q)
                ? q.length
                : /^d+$/.test(q)
                    ? -1 * (type === "perfectable" ? q.length : q.length + 1)
                    : 0;
}
// return the interval name of a pitch
function pitchName$1(props) {
    const { step, alt, oct = 0, dir } = props;
    if (!dir) {
        return "";
    }
    const num = step + 1 + 7 * oct;
    const d = dir < 0 ? "-" : "";
    const type = TYPES[step] === "M" ? "majorable" : "perfectable";
    const name = d + num + altToQ(type, alt);
    return name;
}
const fillStr$1 = (s, n) => Array(Math.abs(n) + 1).join(s);
function altToQ(type, alt) {
    if (alt === 0) {
        return type === "majorable" ? "M" : "P";
    }
    else if (alt === -1 && type === "majorable") {
        return "m";
    }
    else if (alt > 0) {
        return fillStr$1("A", alt);
    }
    else {
        return fillStr$1("d", type === "perfectable" ? alt : alt + 1);
    }
}

/**
 * Transpose a note by an interval.
 *
 * @param {string} note - the note or note name
 * @param {string} interval - the interval or interval name
 * @return {string} the transposed note name or empty string if not valid notes
 * @example
 * import { tranpose } from "@tonaljs/tonal"
 * transpose("d3", "3M") // => "F#3"
 * transpose("D", "3M") // => "F#"
 * ["C", "D", "E", "F", "G"].map(pc => transpose(pc, "M3)) // => ["E", "F#", "G#", "A", "B"]
 */
function transpose(noteName, intervalName) {
    const note$1 = note(noteName);
    const interval$1 = interval(intervalName);
    if (note$1.empty || interval$1.empty) {
        return "";
    }
    const noteCoord = note$1.coord;
    const intervalCoord = interval$1.coord;
    const tr = noteCoord.length === 1
        ? [noteCoord[0] + intervalCoord[0]]
        : [noteCoord[0] + intervalCoord[0], noteCoord[1] + intervalCoord[1]];
    return coordToNote(tr).name;
}
/**
 * Find the interval distance between two notes or coord classes.
 *
 * To find distance between coord classes, both notes must be coord classes and
 * the interval is always ascending
 *
 * @param {Note|string} from - the note or note name to calculate distance from
 * @param {Note|string} to - the note or note name to calculate distance to
 * @return {string} the interval name or empty string if not valid notes
 *
 */
function distance(fromNote, toNote) {
    const from = note(fromNote);
    const to = note(toNote);
    if (from.empty || to.empty) {
        return "";
    }
    const fcoord = from.coord;
    const tcoord = to.coord;
    const fifths = tcoord[0] - fcoord[0];
    const octs = fcoord.length === 2 && tcoord.length === 2
        ? tcoord[1] - fcoord[1]
        : -Math.floor((fifths * 7) / 12);
    return coordToInterval([fifths, octs]).name;
}

export { accToAlt, altToAcc, coordToInterval, coordToNote, decode, distance, encode, interval, isNamed, isPitch, note, tokenize$1 as tokenizeInterval, tokenize as tokenizeNote, transpose };
//# sourceMappingURL=index.esnext.js.map
