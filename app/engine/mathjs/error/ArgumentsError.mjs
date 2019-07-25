/**
 * Create a syntax error with the message:
 *     'Wrong number of arguments in function <fn> (<count> provided, <min>-<max> expected)'
 * @param {string} fn     Function name
 * @param {number} count  Actual argument count
 * @param {number} min    Minimum required argument count
 * @param {number} [max]  Maximum required argument count
 * @extends Error
 */
export class ArgumentsError extends RangeError {

    constructor(fn, count, min, max) {
	this.fn = fn
	this.count = count
	this.min = min
	this.max = max

	this.message = 'Wrong number of arguments in function ' + fn +
	    ' (' + count + ' provided, ' +
	    min + ((max !== undefined && max !== null) ? ('-' + max) : '') + ' expected)'
	super(this.message)
	
	this.stack = (new Error()).stack
    }

    static get name() {
	return 'ArgumentsError'
    }

    static get isArgumentsError() {
	return true
    }
}

