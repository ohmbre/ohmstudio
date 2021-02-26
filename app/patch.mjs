
class Patch {
    constructor(def) {
        this.modules = []
	Object.assign(this,def || {})
    }
    
    get cables() {
	return this.modules
	    .map(module => module.cables())
	    .reduce(concat, [])
    }


}

class Module {
    constructor(def) {
	this.name = "module"
	this.tags = ["uncategorized"]
	this.inJacks = []
	this.outJacks = []
	this.controls = []
	Object.assign(this,def || {});
    }

    get cables() {
	return this.outJacks
	    .map(outJack => outJack.cables)
	    .reduce(concat)ab
    }
}

class InJack {
    constructor(def = {}) {
	this.label = "input"
	this.connected = false
	Object.assign(this, def)
    }
}

class OutJack {
    constructor(def = {}) {
	this.label = "output"
	this.expression = "0"
	this.cables = []
	Object.assign(this, def)
    }
}
