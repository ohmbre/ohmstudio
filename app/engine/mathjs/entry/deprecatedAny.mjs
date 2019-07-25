// TODO: deprecated since version 6.0.0. Date: 2019-04-14

// "deprecatedEval" is also exposed as "eval" in the code compiled to ES5+CommonJs
import { createDeprecatedEval } from '../expression/function/eval.mjs'
import { createDeprecatedImport } from '../core/function/deprecatedImport.mjs'
import { createDeprecatedVar } from '../function/statistics/variance.mjs'
import { createDeprecatedTypeof } from '../function/utils/typeOf.mjs'
import {
  isAccessorNode,
  isArray,
  isArrayNode,
  isAssignmentNode,
  isBigNumber,
  isBlockNode,
  isBoolean, isChain, isCollection,
  isComplex,
  isConditionalNode,
  isConstantNode,
  isDate,
  isDenseMatrix,
  isFraction,
  isFunction,
  isFunctionAssignmentNode,
  isFunctionNode,
  isHelp,
  isIndex,
  isIndexNode,
  isMatrix,
  isNode,
  isNull,
  isNumber,
  isObject,
  isObjectNode,
  isOperatorNode,
  isParenthesisNode,
  isRange,
  isRangeNode,
  isRegExp,
  isResultSet,
  isSparseMatrix,
  isString, isSymbolNode,
  isUndefined,
  isUnit
} from '../utils/is.mjs'
import { ArgumentsError } from '../error/ArgumentsError.mjs'
import { DimensionError } from '../error/DimensionError.mjs'
import { IndexError } from '../error/IndexError.mjs'
import { lazy } from '../utils/object.mjs'
import { warnOnce } from '../utils/log.mjs'
import {
  BigNumber,
  Complex,
  DenseMatrix,
  FibonacciHeap,
  Fraction,
  ImmutableDenseMatrix,
  Index,
  Matrix,
  ResultSet,
  Range,
  Spa,
  SparseMatrix,
  typeOf,
  Unit,
  variance
} from './pureFunctionsAny.generated.mjs'
import {
  AccessorNode,
  ArrayNode,
  AssignmentNode,
  BlockNode,
  Chain,
  ConditionalNode,
  ConstantNode,
  evaluate,
  FunctionAssignmentNode,
  FunctionNode,
  Help,
  IndexNode,
  Node,
  ObjectNode,
  OperatorNode,
  ParenthesisNode,
  parse,
  Parser,
  RangeNode,
  RelationalNode,
  reviver,
  SymbolNode
} from './impureFunctionsAny.generated.mjs'

export const deprecatedEval = /* #__PURE__ */ createDeprecatedEval({ evaluate })

// "deprecatedImport" is also exposed as "import" in the code compiled to ES5+CommonJs
export const deprecatedImport = /* #__PURE__ */ createDeprecatedImport({})

// "deprecatedVar" is also exposed as "var" in the code compiled to ES5+CommonJs
export const deprecatedVar = /* #__PURE__ */ createDeprecatedVar({ variance })

// "deprecatedTypeof" is also exposed as "typeof" in the code compiled to ES5+CommonJs
export const deprecatedTypeof = /* #__PURE__ */ createDeprecatedTypeof({ typeOf })

export const type = /* #__PURE__ */ createDeprecatedProperties('type', {
  isNumber,
  isComplex,
  isBigNumber,
  isFraction,
  isUnit,
  isString,
  isArray,
  isMatrix,
  isCollection,
  isDenseMatrix,
  isSparseMatrix,
  isRange,
  isIndex,
  isBoolean,
  isResultSet,
  isHelp,
  isFunction,
  isDate,
  isRegExp,
  isObject,
  isNull,
  isUndefined,
  isAccessorNode,
  isArrayNode,
  isAssignmentNode,
  isBlockNode,
  isConditionalNode,
  isConstantNode,
  isFunctionAssignmentNode,
  isFunctionNode,
  isIndexNode,
  isNode,
  isObjectNode,
  isOperatorNode,
  isParenthesisNode,
  isRangeNode,
  isSymbolNode,
  isChain,
  BigNumber,
  Chain,
  Complex,
  Fraction,
  Matrix,
  DenseMatrix,
  SparseMatrix,
  Spa,
  FibonacciHeap,
  ImmutableDenseMatrix,
  Index,
  Range,
  ResultSet,
  Unit,
  Help,
  Parser
})

export const expression = /* #__PURE__ */ createDeprecatedProperties('expression', {
  parse,
  Parser,
  node: createDeprecatedProperties('expression.node', {
    AccessorNode,
    ArrayNode,
    AssignmentNode,
    BlockNode,
    ConditionalNode,
    ConstantNode,
    IndexNode,
    FunctionAssignmentNode,
    FunctionNode,
    Node,
    ObjectNode,
    OperatorNode,
    ParenthesisNode,
    RangeNode,
    RelationalNode,
    SymbolNode
  })
})

export const json = /* #__PURE__ */ createDeprecatedProperties('json', {
  reviver
})

export const error = /* #__PURE__ */ createDeprecatedProperties('error', {
  ArgumentsError,
  DimensionError,
  IndexError
})

function createDeprecatedProperties (path, props) {
  const obj = {}

  Object.keys(props).forEach(name => {
    lazy(obj, name, () => {
      warnOnce(`math.${path}.${name} is moved to math.${name} in v6.0.0. ` +
        'Please use the new location instead.')
      return props[name]
    })
  })

  return obj
}
