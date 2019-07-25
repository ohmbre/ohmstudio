import { factory } from '../../utils/factory.mjs'
import { errorTransform } from './utils/errorTransform.mjs'
import { createSubset } from '../../function/matrix/subset.mjs'

const name = 'subset'
const dependencies = ['typed', 'matrix']

export const createSubsetTransform = /* #__PURE__ */ factory(name, dependencies, ({ typed, matrix }) => {
  const subset = createSubset({ typed, matrix })

  /**
   * Attach a transform function to math.subset
   * Adds a property transform containing the transform function.
   *
   * This transform creates a range which includes the end value
   */
  return typed('subset', {
    '...any': function (args) {
      try {
        return subset.apply(null, args)
      } catch (err) {
        throw errorTransform(err)
      }
    }
  })
}, { isTransformFunction: true })
