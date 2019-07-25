import {
  absNumber,
  acoshNumber,
  acosNumber,
  acothNumber,
  acotNumber,
  acschNumber,
  acscNumber,
  addNumber,
  andNumber,
  asechNumber,
  asecNumber,
  asinhNumber,
  asinNumber,
  atan2Number,
  atanhNumber,
  atanNumber,
  bitAndNumber,
  bitNotNumber,
  bitOrNumber,
  bitXorNumber,
  cbrtNumber,
  ceilNumber,
  combinationsNumber,
  coshNumber,
  cosNumber,
  cothNumber,
  cotNumber,
  cschNumber,
  cscNumber,
  cubeNumber,
  divideNumber,
  expm1Number,
  expNumber,
  fixNumber,
  floorNumber,
  gammaNumber,
  gcdNumber,
  isIntegerNumber,
  isNaNNumber,
  isNegativeNumber,
  isPositiveNumber,
  isZeroNumber,
  lcmNumber,
  leftShiftNumber,
  log10Number,
  log1pNumber,
  log2Number,
  logNumber,
  modNumber,
  multiplyNumber,
  normNumber,
  notNumber,
  orNumber,
  powNumber,
  rightArithShiftNumber,
  rightLogShiftNumber,
  sechNumber,
  secNumber,
  signNumber,
  sinhNumber,
  sinNumber,
  sqrtNumber,
  squareNumber,
  subtractNumber,
  tanhNumber,
  tanNumber,
  unaryMinusNumber,
  unaryPlusNumber,
  xgcdNumber,
  xorNumber
} from './plain/number.mjs'

import { factory } from './utils/factory.mjs'
import { noIndexClass, noMatrix, noSubset } from './utils/noop.mjs'

// ----------------------------------------------------------------------------
// classes and functions

// core
export { createTyped } from './core/function/typed.mjs'

// classes
export { createResultSet } from './type/resultset/ResultSet.mjs'
export { createRangeClass } from './type/matrix/Range.mjs'
export { createHelpClass } from './expression/Help.mjs'
export { createChainClass } from './type/chain/Chain.mjs'
export { createHelp } from './expression/function/help.mjs'
export { createChain } from './type/chain/function/chain.mjs'

// algebra
export { createSimplify } from './function/algebra/simplify.mjs'
export { createDerivative } from './function/algebra/derivative.mjs'
export { createRationalize } from './function/algebra/rationalize.mjs'

// arithmetic
export const createUnaryMinus = /* #__PURE__ */ createNumberFactory('unaryMinus', unaryMinusNumber)
export const createUnaryPlus = /* #__PURE__ */ createNumberFactory('unaryPlus', unaryPlusNumber)
export const createAbs = /* #__PURE__ */ createNumberFactory('abs', absNumber)
export const createAddScalar = /* #__PURE__ */ createNumberFactory('addScalar', addNumber)
export const createCbrt = /* #__PURE__ */ createNumberFactory('cbrt', cbrtNumber)
export const createCeil = /* #__PURE__ */ createNumberFactory('ceil', ceilNumber)
export const createCube = /* #__PURE__ */ createNumberFactory('cube', cubeNumber)
export const createExp = /* #__PURE__ */ createNumberFactory('exp', expNumber)
export const createExpm1 = /* #__PURE__ */ createNumberFactory('expm1', expm1Number)
export const createFix = /* #__PURE__ */ createNumberFactory('fix', fixNumber)
export const createFloor = /* #__PURE__ */ createNumberFactory('floor', floorNumber)
export const createGcd = /* #__PURE__ */ createNumberFactory('gcd', gcdNumber)
export const createLcm = /* #__PURE__ */ createNumberFactory('lcm', lcmNumber)
export const createLog10 = /* #__PURE__ */ createNumberFactory('log10', log10Number)
export const createLog2 = /* #__PURE__ */ createNumberFactory('log2', log2Number)
export const createMod = /* #__PURE__ */ createNumberFactory('mod', modNumber)
export const createMultiplyScalar = /* #__PURE__ */ createNumberFactory('multiplyScalar', multiplyNumber)
export const createMultiply = /* #__PURE__ */ createNumberFactory('multiply', multiplyNumber)
export { createNthRootNumber as createNthRoot } from './function/arithmetic/nthRoot.mjs'
export const createSign = /* #__PURE__ */ createNumberFactory('sign', signNumber)
export const createSqrt = /* #__PURE__ */ createNumberFactory('sqrt', sqrtNumber)
export const createSquare = /* #__PURE__ */ createNumberFactory('square', squareNumber)
export const createSubtract = /* #__PURE__ */ createNumberFactory('subtract', subtractNumber)
export const createXgcd = /* #__PURE__ */ createNumberFactory('xgcd', xgcdNumber)
export const createDivideScalar = /* #__PURE__ */ createNumberFactory('divideScalar', divideNumber)
export const createPow = /* #__PURE__ */ createNumberFactory('pow', powNumber)
export { createRoundNumber as createRound } from './function/arithmetic/round.mjs'
export const createLog = /* #__PURE__ */ createNumberFactory('log', logNumber)
export const createLog1p = /* #__PURE__ */ createNumberFactory('log1p', log1pNumber)
export const createAdd = /* #__PURE__ */ createNumberFactory('add', addNumber)
export { createHypot } from './function/arithmetic/hypot.mjs'
export const createNorm = /* #__PURE__ */ createNumberFactory('norm', normNumber)
export const createDivide = /* #__PURE__ */ createNumberFactory('divide', divideNumber)

// bitwise
export const createBitAnd = /* #__PURE__ */ createNumberFactory('bitAnd', bitAndNumber)
export const createBitNot = /* #__PURE__ */ createNumberFactory('bitNot', bitNotNumber)
export const createBitOr = /* #__PURE__ */ createNumberFactory('bitOr', bitOrNumber)
export const createBitXor = /* #__PURE__ */ createNumberFactory('bitXor', bitXorNumber)
export const createLeftShift = /* #__PURE__ */ createNumberFactory('leftShift', leftShiftNumber)
export const createRightArithShift = /* #__PURE__ */ createNumberFactory('rightArithShift', rightArithShiftNumber)
export const createRightLogShift = /* #__PURE__ */ createNumberFactory('rightLogShift', rightLogShiftNumber)

// combinatorics
export { createStirlingS2 } from './function/combinatorics/stirlingS2.mjs'
export { createBellNumbers } from './function/combinatorics/bellNumbers.mjs'
export { createCatalan } from './function/combinatorics/catalan.mjs'
export { createComposition } from './function/combinatorics/composition.mjs'

// constants
export {
  createE,
  createUppercaseE,
  createFalse,
  // createI,
  createInfinity,
  createLN10,
  createLN2,
  createLOG10E,
  createLOG2E,
  createNaN,
  createNull,
  createPhi,
  createPi,
  createUppercasePi,
  createSQRT1_2, // eslint-disable-line camelcase
  createSQRT2,
  createTau,
  createTrue,
  createVersion
} from './constants.mjs'

// create
export { createNumber } from './type/number.mjs'
export { createString } from './type/string.mjs'
export { createBoolean } from './type/boolean.mjs'
export { createParser } from './expression/function/parser.mjs'

// expression
export { createNode } from './expression/node/Node.mjs'
export { createAccessorNode } from './expression/node/AccessorNode.mjs'
export { createArrayNode } from './expression/node/ArrayNode.mjs'
export { createAssignmentNode } from './expression/node/AssignmentNode.mjs'
export { createBlockNode } from './expression/node/BlockNode.mjs'
export { createConditionalNode } from './expression/node/ConditionalNode.mjs'
export { createConstantNode } from './expression/node/ConstantNode.mjs'
export { createFunctionAssignmentNode } from './expression/node/FunctionAssignmentNode.mjs'
export { createIndexNode } from './expression/node/IndexNode.mjs'
export { createObjectNode } from './expression/node/ObjectNode.mjs'
export { createOperatorNode } from './expression/node/OperatorNode.mjs'
export { createParenthesisNode } from './expression/node/ParenthesisNode.mjs'
export { createRangeNode } from './expression/node/RangeNode.mjs'
export { createRelationalNode } from './expression/node/RelationalNode.mjs'
export { createSymbolNode } from './expression/node/SymbolNode.mjs'
export { createFunctionNode } from './expression/node/FunctionNode.mjs'
export { createParse } from './expression/parse.mjs'
export { createCompile } from './expression/function/compile.mjs'
export { createEvaluate } from './expression/function/evaluate.mjs'
export { createParserClass } from './expression/Parser.mjs'

// logical
export const createAnd = /* #__PURE__ */ createNumberFactory('and', andNumber)
export const createNot = /* #__PURE__ */ createNumberFactory('not', notNumber)
export const createOr = /* #__PURE__ */ createNumberFactory('or', orNumber)
export const createXor = /* #__PURE__ */ createNumberFactory('xor', xorNumber)

// matrix
export { createApply } from './function/matrix/apply.mjs'
export { createFilter } from './function/matrix/filter.mjs'
export { createForEach } from './function/matrix/forEach.mjs'
export { createMap } from './function/matrix/map.mjs'
export { createRange } from './function/matrix/range.mjs'
export { createSize } from './function/matrix/size.mjs'
// FIXME: create a lightweight "number" implementation of subset only supporting plain objects/arrays
export const createIndexClass = /* #__PURE__ */ factory('Index', [], () => noIndexClass, { isClass: true })
export const createMatrix = /* #__PURE__ */ factory('matrix', [], () => noMatrix) // FIXME: needed now because subset transform needs it. Remove the need for it in subset
export const createSubset = /* #__PURE__ */ factory('subset', [], () => noSubset)
// TODO: provide number+array implementations for map, filter, forEach, zeros, ...?
// TODO: create range implementation for range?
export { createPartitionSelect } from './function/matrix/partitionSelect.mjs'

// probability
export const createCombinations = createNumberFactory('combinations', combinationsNumber)
export const createGamma = createNumberFactory('gamma', gammaNumber)
export { createFactorial } from './function/probability/factorial.mjs'
export { createMultinomial } from './function/probability/multinomial.mjs'
export { createPermutations } from './function/probability/permutations.mjs'
export { createPickRandom } from './function/probability/pickRandom.mjs'
export { createRandomNumber as createRandom } from './function/probability/random.mjs'
export { createRandomInt } from './function/probability/randomInt.mjs'

// relational
export { createEqualScalarNumber as createEqualScalar } from './function/relational/equalScalar.mjs'
export { createCompareNumber as createCompare } from './function/relational/compare.mjs'
export { createCompareNatural } from './function/relational/compareNatural.mjs'
export { createCompareTextNumber as createCompareText } from './function/relational/compareText.mjs'
export { createEqualNumber as createEqual } from './function/relational/equal.mjs'
export { createEqualText } from './function/relational/equalText.mjs'
export { createSmallerNumber as createSmaller } from './function/relational/smaller.mjs'
export { createSmallerEqNumber as createSmallerEq } from './function/relational/smallerEq.mjs'
export { createLargerNumber as createLarger } from './function/relational/larger.mjs'
export { createLargerEqNumber as createLargerEq } from './function/relational/largerEq.mjs'
export { createDeepEqual } from './function/relational/deepEqual.mjs'
export { createUnequalNumber as createUnequal } from './function/relational/unequal.mjs'

// special
export { createErf } from './function/special/erf.mjs'

// statistics
export { createMode } from './function/statistics/mode.mjs'
export { createProd } from './function/statistics/prod.mjs'
export { createMax } from './function/statistics/max.mjs'
export { createMin } from './function/statistics/min.mjs'
export { createSum } from './function/statistics/sum.mjs'
export { createMean } from './function/statistics/mean.mjs'
export { createMedian } from './function/statistics/median.mjs'
export { createMad } from './function/statistics/mad.mjs'
export { createVariance } from './function/statistics/variance.mjs'
export { createQuantileSeq } from './function/statistics/quantileSeq.mjs'
export { createStd } from './function/statistics/std.mjs'

// string
export { createFormat } from './function/string/format.mjs'
export { createPrint } from './function/string/print.mjs'

// trigonometry
export const createAcos = /* #__PURE__ */ createNumberFactory('acos', acosNumber)
export const createAcosh = /* #__PURE__ */ createNumberFactory('acosh', acoshNumber)
export const createAcot = /* #__PURE__ */ createNumberFactory('acot', acotNumber)
export const createAcoth = /* #__PURE__ */ createNumberFactory('acoth', acothNumber)
export const createAcsc = /* #__PURE__ */ createNumberFactory('acsc', acscNumber)
export const createAcsch = /* #__PURE__ */ createNumberFactory('acsch', acschNumber)
export const createAsec = /* #__PURE__ */ createNumberFactory('asec', asecNumber)
export const createAsech = /* #__PURE__ */ createNumberFactory('asech', asechNumber)
export const createAsin = /* #__PURE__ */ createNumberFactory('asin', asinNumber)
export const createAsinh = /* #__PURE__ */ createNumberFactory('asinh', asinhNumber)
export const createAtan = /* #__PURE__ */ createNumberFactory('atan', atanNumber)
export const createAtan2 = /* #__PURE__ */ createNumberFactory('atan2', atan2Number)
export const createAtanh = /* #__PURE__ */ createNumberFactory('atanh', atanhNumber)
export const createCos = /* #__PURE__ */ createNumberFactory('cos', cosNumber)
export const createCosh = /* #__PURE__ */ createNumberFactory('cosh', coshNumber)
export const createCot = /* #__PURE__ */ createNumberFactory('cot', cotNumber)
export const createCoth = /* #__PURE__ */ createNumberFactory('coth', cothNumber)
export const createCsc = /* #__PURE__ */ createNumberFactory('csc', cscNumber)
export const createCsch = /* #__PURE__ */ createNumberFactory('csch', cschNumber)
export const createSec = /* #__PURE__ */ createNumberFactory('sec', secNumber)
export const createSech = /* #__PURE__ */ createNumberFactory('sech', sechNumber)
export const createSin = /* #__PURE__ */ createNumberFactory('sin', sinNumber)
export const createSinh = /* #__PURE__ */ createNumberFactory('sinh', sinhNumber)
export const createTan = /* #__PURE__ */ createNumberFactory('tan', tanNumber)
export const createTanh = /* #__PURE__ */ createNumberFactory('tanh', tanhNumber)

// transforms
export { createApplyTransform } from './expression/transform/apply.transform.mjs'
export { createFilterTransform } from './expression/transform/filter.transform.mjs'
export { createForEachTransform } from './expression/transform/forEach.transform.mjs'
export { createMapTransform } from './expression/transform/map.transform.mjs'
export { createMaxTransform } from './expression/transform/max.transform.mjs'
export { createMeanTransform } from './expression/transform/mean.transform.mjs'
export { createMinTransform } from './expression/transform/min.transform.mjs'
export { createRangeTransform } from './expression/transform/range.transform.mjs'
export { createSubsetTransform } from './expression/transform/subset.transform.mjs'
export { createStdTransform } from './expression/transform/std.transform.mjs'
export { createSumTransform } from './expression/transform/sum.transform.mjs'
export { createVarianceTransform } from './expression/transform/variance.transform.mjs'

// utils
export { createClone } from './function/utils/clone.mjs'
export const createIsInteger = /* #__PURE__ */ createNumberFactory('isInteger', isIntegerNumber)
export const createIsNegative = /* #__PURE__ */ createNumberFactory('isNegative', isNegativeNumber)
export { createIsNumeric } from './function/utils/isNumeric.mjs'
export { createHasNumericValue } from './function/utils/hasNumericValue.mjs'
export const createIsPositive = /* #__PURE__ */ createNumberFactory('isPositive', isPositiveNumber)
export const createIsZero = /* #__PURE__ */ createNumberFactory('isZero', isZeroNumber)
export const createIsNaN = /* #__PURE__ */ createNumberFactory('isNaN', isNaNNumber)
export { createTypeOf } from './function/utils/typeOf.mjs'
export { createIsPrime } from './function/utils/isPrime.mjs'
export { createNumeric } from './function/utils/numeric.mjs'

// json
export { createReviver } from './json/reviver.mjs'

// helper function to create a factory function for a function which only needs typed-function
function createNumberFactory (name, fn) {
  return factory(name, ['typed'], ({ typed }) => typed(fn))
}
