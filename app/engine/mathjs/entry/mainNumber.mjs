// configuration
export { config } from './configReadonly.mjs'

// functions and constants
export * from './pureFunctionsNumber.generated.mjs'
export * from './impureFunctionsNumber.generated.mjs'
export * from './typeChecks.mjs'

// error classes
export { IndexError } from '../error/IndexError.mjs'
export { DimensionError } from '../error/DimensionError.mjs'
export { ArgumentsError } from '../error/ArgumentsError.mjs'

// dependency groups
export * from './dependenciesNumber.generated.mjs'

// factory functions
export * from '../factoriesNumber.mjs'

// core
export { create } from '../core/create.mjs'
export { factory } from '../utils/factory.mjs'
