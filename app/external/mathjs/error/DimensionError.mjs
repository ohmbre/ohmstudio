/**
 * Create a range error with the message:
 *     'Dimension mismatch (<actual size> != <expected size>)'
 * @param {number | number[]} actual        The actual size
 * @param {number | number[]} expected      The expected size
 * @param {string} [relation='!=']          Optional relation between actual
 *                                          and expected size: '!=', '<', etc.
 * @extends RangeError
 */
export class DimensionError extends RangeError{
    constructor(actual, expected, relation) {
	this.actual = actual
	this.expected = expected
	this.relation = relation
	super('Dimension mismatch (' +
	      (Array.isArray(actual) ? ('[' + actual.join(', ') + ']') : actual) +
	      ' ' + (this.relation || '!=') + ' ' +
	      (Array.isArray(expected) ? ('[' + expected.join(', ') + ']') : expected)+')')
	this.stack = (new Error()).stack
    }

    static get name() {
	return 'DimensionError'
    }

    static get isDimensionError() {
	return true;
    }
}

