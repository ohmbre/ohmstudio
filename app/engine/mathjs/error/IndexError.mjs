/**
 * Create a range error with the message:
 *     'Index out of range (index < min)'
 *     'Index out of range (index < max)'
 *
 * @param {number} index     The actual index
 * @param {number} [min=0]   Minimum index (included)
 * @param {number} [max]     Maximum index (excluded)
 * @extends RangeError
 */
export class IndexError extends RangeError {
    constructor(index, min, max) {
	this.index = index
	if (arguments.length < 3) {
	    this.min = 0
	    this.max = min
	} else {
	    this.min = min
	    this.max = max
	}

	if (this.min !== undefined && this.index < this.min) {
	    this.message = 'Index out of range (' + this.index + ' < ' + this.min + ')'
	} else if (this.max !== undefined && this.index >= this.max) {
	    this.message = 'Index out of range (' + this.index + ' > ' + (this.max - 1) + ')'
	} else {
	    this.message = 'Index out of range (' + this.index + ')'
	}

	super(this.message)
	
	this.stack = (new Error()).stack
    }

    static get name() {
	return 'IndexError'
    }

    static get isIndexError() {
	return true
    }
}


