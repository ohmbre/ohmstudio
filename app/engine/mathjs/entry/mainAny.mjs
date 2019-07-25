// configuration
export { config } from './configReadonly.mjs'

// functions and constants
export * from './pureFunctionsAny.generated.mjs'
export * from './impureFunctionsAny.generated.mjs'
export * from './typeChecks.mjs'

// error classes
export { IndexError } from '../error/IndexError.mjs'
export { DimensionError } from '../error/DimensionError.mjs'
export { ArgumentsError } from '../error/ArgumentsError.mjs'

// dependency groups
export * from './dependenciesAny.generated.mjs'

// factory functions
export * from '../factoriesAny.mjs'

// core
export { create } from '../core/create.mjs'
export { factory } from '../utils/factory.mjs'

// backward compatibility stuff for v5
export * from './deprecatedAny.mjs'
