import { bignumberDocs } from './construction/bignumber.mjs'
import { typeOfDocs } from './function/utils/typeOf.mjs'
import { isZeroDocs } from './function/utils/isZero.mjs'
import { isPrimeDocs } from './function/utils/isPrime.mjs'
import { isPositiveDocs } from './function/utils/isPositive.mjs'
import { isNumericDocs } from './function/utils/isNumeric.mjs'
import { hasNumericValueDocs } from './function/utils/hasNumericValue.mjs'
import { isNegativeDocs } from './function/utils/isNegative.mjs'
import { isIntegerDocs } from './function/utils/isInteger.mjs'
import { isNaNDocs } from './function/utils/isNaN.mjs'
import { formatDocs } from './function/utils/format.mjs'
import { cloneDocs } from './function/utils/clone.mjs'
import { toDocs } from './function/units/to.mjs'
import { tanhDocs } from './function/trigonometry/tanh.mjs'
import { tanDocs } from './function/trigonometry/tan.mjs'
import { sinhDocs } from './function/trigonometry/sinh.mjs'
import { sechDocs } from './function/trigonometry/sech.mjs'
import { secDocs } from './function/trigonometry/sec.mjs'
import { cschDocs } from './function/trigonometry/csch.mjs'
import { cscDocs } from './function/trigonometry/csc.mjs'
import { cothDocs } from './function/trigonometry/coth.mjs'
import { cotDocs } from './function/trigonometry/cot.mjs'
import { coshDocs } from './function/trigonometry/cosh.mjs'
import { cosDocs } from './function/trigonometry/cos.mjs'
import { atan2Docs } from './function/trigonometry/atan2.mjs'
import { atanhDocs } from './function/trigonometry/atanh.mjs'
import { atanDocs } from './function/trigonometry/atan.mjs'
import { asinhDocs } from './function/trigonometry/asinh.mjs'
import { asinDocs } from './function/trigonometry/asin.mjs'
import { asechDocs } from './function/trigonometry/asech.mjs'
import { asecDocs } from './function/trigonometry/asec.mjs'
import { acschDocs } from './function/trigonometry/acsch.mjs'
import { acscDocs } from './function/trigonometry/acsc.mjs'
import { acothDocs } from './function/trigonometry/acoth.mjs'
import { acotDocs } from './function/trigonometry/acot.mjs'
import { acoshDocs } from './function/trigonometry/acosh.mjs'
import { acosDocs } from './function/trigonometry/acos.mjs'
import { sumDocs } from './function/statistics/sum.mjs'
import { stdDocs } from './function/statistics/std.mjs'
import { quantileSeqDocs } from './function/statistics/quantileSeq.mjs'
import { prodDocs } from './function/statistics/prod.mjs'
import { modeDocs } from './function/statistics/mode.mjs'
import { minDocs } from './function/statistics/min.mjs'
import { medianDocs } from './function/statistics/median.mjs'
import { meanDocs } from './function/statistics/mean.mjs'
import { maxDocs } from './function/statistics/max.mjs'
import { madDocs } from './function/statistics/mad.mjs'
import { erfDocs } from './function/special/erf.mjs'
import { setUnionDocs } from './function/set/setUnion.mjs'
import { setSymDifferenceDocs } from './function/set/setSymDifference.mjs'
import { setSizeDocs } from './function/set/setSize.mjs'
import { setPowersetDocs } from './function/set/setPowerset.mjs'
import { setMultiplicityDocs } from './function/set/setMultiplicity.mjs'
import { setIsSubsetDocs } from './function/set/setIsSubset.mjs'
import { setIntersectDocs } from './function/set/setIntersect.mjs'
import { setDistinctDocs } from './function/set/setDistinct.mjs'
import { setDifferenceDocs } from './function/set/setDifference.mjs'
import { setCartesianDocs } from './function/set/setCartesian.mjs'
import { unequalDocs } from './function/relational/unequal.mjs'
import { smallerEqDocs } from './function/relational/smallerEq.mjs'
import { smallerDocs } from './function/relational/smaller.mjs'
import { largerEqDocs } from './function/relational/largerEq.mjs'
import { largerDocs } from './function/relational/larger.mjs'
import { equalTextDocs } from './function/relational/equalText.mjs'
import { equalDocs } from './function/relational/equal.mjs'
import { deepEqualDocs } from './function/relational/deepEqual.mjs'
import { compareTextDocs } from './function/relational/compareText.mjs'
import { compareNaturalDocs } from './function/relational/compareNatural.mjs'
import { compareDocs } from './function/relational/compare.mjs'
import { randomIntDocs } from './function/probability/randomInt.mjs'
import { randomDocs } from './function/probability/random.mjs'
import { pickRandomDocs } from './function/probability/pickRandom.mjs'
import { permutationsDocs } from './function/probability/permutations.mjs'
import { multinomialDocs } from './function/probability/multinomial.mjs'
import { kldivergenceDocs } from './function/probability/kldivergence.mjs'
import { gammaDocs } from './function/probability/gamma.mjs'
import { factorialDocs } from './function/probability/factorial.mjs'
import { combinationsDocs } from './function/probability/combinations.mjs'
import { zerosDocs } from './function/matrix/zeros.mjs'
import { transposeDocs } from './function/matrix/transpose.mjs'
import { traceDocs } from './function/matrix/trace.mjs'
import { subsetDocs } from './function/matrix/subset.mjs'
import { squeezeDocs } from './function/matrix/squeeze.mjs'
import { sortDocs } from './function/matrix/sort.mjs'
import { sizeDocs } from './function/matrix/size.mjs'
import { reshapeDocs } from './function/matrix/reshape.mjs'
import { resizeDocs } from './function/matrix/resize.mjs'
import { rangeDocs } from './function/matrix/range.mjs'
import { partitionSelectDocs } from './function/matrix/partitionSelect.mjs'
import { onesDocs } from './function/matrix/ones.mjs'
import { mapDocs } from './function/matrix/map.mjs'
import { kronDocs } from './function/matrix/kron.mjs'
import { invDocs } from './function/matrix/inv.mjs'
import { forEachDocs } from './function/matrix/forEach.mjs'
import { flattenDocs } from './function/matrix/flatten.mjs'
import { filterDocs } from './function/matrix/filter.mjs'
import { identityDocs } from './function/matrix/identity.mjs'
import { getMatrixDataTypeDocs } from './function/matrix/getMatrixDataType.mjs'
import { dotDocs } from './function/matrix/dot.mjs'
import { diagDocs } from './function/matrix/diag.mjs'
import { detDocs } from './function/matrix/det.mjs'
import { ctransposeDocs } from './function/matrix/ctranspose.mjs'
import { crossDocs } from './function/matrix/cross.mjs'
import { concatDocs } from './function/matrix/concat.mjs'
import { xorDocs } from './function/logical/xor.mjs'
import { orDocs } from './function/logical/or.mjs'
import { notDocs } from './function/logical/not.mjs'
import { andDocs } from './function/logical/and.mjs'
import { intersectDocs } from './function/geometry/intersect.mjs'
import { distanceDocs } from './function/geometry/distance.mjs'
import { helpDocs } from './function/expression/help.mjs'
import { evaluateDocs } from './function/expression/evaluate.mjs'
import { imDocs } from './function/complex/im.mjs'
import { reDocs } from './function/complex/re.mjs'
import { conjDocs } from './function/complex/conj.mjs'
import { argDocs } from './function/complex/arg.mjs'
import { typedDocs } from './core/typed.mjs'
import { importDocs } from './core/import.mjs'
import { configDocs } from './core/config.mjs'
import { stirlingS2Docs } from './function/combinatorics/stirlingS2.mjs'
import { compositionDocs } from './function/combinatorics/composition.mjs'
import { catalanDocs } from './function/combinatorics/catalan.mjs'
import { bellNumbersDocs } from './function/combinatorics/bellNumbers.mjs'
import { rightLogShiftDocs } from './function/bitwise/rightLogShift.mjs'
import { rightArithShiftDocs } from './function/bitwise/rightArithShift.mjs'
import { leftShiftDocs } from './function/bitwise/leftShift.mjs'
import { bitXorDocs } from './function/bitwise/bitXor.mjs'
import { bitOrDocs } from './function/bitwise/bitOr.mjs'
import { bitNotDocs } from './function/bitwise/bitNot.mjs'
import { bitAndDocs } from './function/bitwise/bitAnd.mjs'
import { xgcdDocs } from './function/arithmetic/xgcd.mjs'
import { unaryPlusDocs } from './function/arithmetic/unaryPlus.mjs'
import { unaryMinusDocs } from './function/arithmetic/unaryMinus.mjs'
import { squareDocs } from './function/arithmetic/square.mjs'
import { sqrtmDocs } from './function/arithmetic/sqrtm.mjs'
import { sqrtDocs } from './function/arithmetic/sqrt.mjs'
import { signDocs } from './function/arithmetic/sign.mjs'
import { roundDocs } from './function/arithmetic/round.mjs'
import { powDocs } from './function/arithmetic/pow.mjs'
import { nthRootsDocs } from './function/arithmetic/nthRoots.mjs'
import { nthRootDocs } from './function/arithmetic/nthRoot.mjs'
import { normDocs } from './function/arithmetic/norm.mjs'
import { multiplyDocs } from './function/arithmetic/multiply.mjs'
import { modDocs } from './function/arithmetic/mod.mjs'
import { log10Docs } from './function/arithmetic/log10.mjs'
import { log1pDocs } from './function/arithmetic/log1p.mjs'
import { log2Docs } from './function/arithmetic/log2.mjs'
import { logDocs } from './function/arithmetic/log.mjs'
import { lcmDocs } from './function/arithmetic/lcm.mjs'
import { hypotDocs } from './function/arithmetic/hypot.mjs'
import { gcdDocs } from './function/arithmetic/gcd.mjs'
import { floorDocs } from './function/arithmetic/floor.mjs'
import { fixDocs } from './function/arithmetic/fix.mjs'
import { expm1Docs } from './function/arithmetic/expm1.mjs'
import { expmDocs } from './function/arithmetic/expm.mjs'
import { expDocs } from './function/arithmetic/exp.mjs'
import { dotMultiplyDocs } from './function/arithmetic/dotMultiply.mjs'
import { dotDivideDocs } from './function/arithmetic/dotDivide.mjs'
import { divideDocs } from './function/arithmetic/divide.mjs'
import { cubeDocs } from './function/arithmetic/cube.mjs'
import { ceilDocs } from './function/arithmetic/ceil.mjs'
import { cbrtDocs } from './function/arithmetic/cbrt.mjs'
import { addDocs } from './function/arithmetic/add.mjs'
import { absDocs } from './function/arithmetic/abs.mjs'
import { qrDocs } from './function/algebra/qr.mjs'
import { usolveDocs } from './function/algebra/usolve.mjs'
import { sluDocs } from './function/algebra/slu.mjs'
import { rationalizeDocs } from './function/algebra/rationalize.mjs'
import { simplifyDocs } from './function/algebra/simplify.mjs'
import { lupDocs } from './function/algebra/lup.mjs'
import { lsolveDocs } from './function/algebra/lsolve.mjs'
import { derivativeDocs } from './function/algebra/derivative.mjs'
import { versionDocs } from './constants/version.mjs'
import { trueDocs } from './constants/true.mjs'
import { tauDocs } from './constants/tau.mjs'
import { SQRT2Docs } from './constants/SQRT2.mjs'
import { SQRT12Docs } from './constants/SQRT1_2.mjs'
import { phiDocs } from './constants/phi.mjs'
import { piDocs } from './constants/pi.mjs'
import { nullDocs } from './constants/null.mjs'
import { NaNDocs } from './constants/NaN.mjs'
import { LOG10EDocs } from './constants/LOG10E.mjs'
import { LOG2EDocs } from './constants/LOG2E.mjs'
import { LN10Docs } from './constants/LN10.mjs'
import { LN2Docs } from './constants/LN2.mjs'
import { InfinityDocs } from './constants/Infinity.mjs'
import { iDocs } from './constants/i.mjs'
import { falseDocs } from './constants/false.mjs'
import { eDocs } from './constants/e.mjs'
import { unitDocs } from './construction/unit.mjs'
import { stringDocs } from './construction/string.mjs'
import { splitUnitDocs } from './construction/splitUnit.mjs'
import { sparseDocs } from './construction/sparse.mjs'
import { numberDocs } from './construction/number.mjs'
import { matrixDocs } from './construction/matrix.mjs'
import { indexDocs } from './construction.mjs'
import { fractionDocs } from './construction/fraction.mjs'
import { createUnitDocs } from './construction/createUnit.mjs'
import { complexDocs } from './construction/complex.mjs'
import { booleanDocs } from './construction/boolean.mjs'
import { dotPowDocs } from './function/arithmetic/dotPow.mjs'
import { lusolveDocs } from './function/algebra/lusolve.mjs'
import { subtractDocs } from './function/arithmetic/subtract.mjs'
import { varianceDocs } from './function/statistics/variance.mjs'
import { sinDocs } from './function/trigonometry/sin.mjs'
import { numericDocs } from './function/utils/numeric.mjs'
import { columnDocs } from './function/matrix/column.mjs'
import { rowDocs } from './function/matrix/row.mjs'

export const embeddedDocs = {

  // construction functions
  bignumber: bignumberDocs,
  boolean: booleanDocs,
  complex: complexDocs,
  createUnit: createUnitDocs,
  fraction: fractionDocs,
  index: indexDocs,
  matrix: matrixDocs,
  number: numberDocs,
  sparse: sparseDocs,
  splitUnit: splitUnitDocs,
  string: stringDocs,
  unit: unitDocs,

  // constants
  e: eDocs,
  E: eDocs,
  false: falseDocs,
  i: iDocs,
  Infinity: InfinityDocs,
  LN2: LN2Docs,
  LN10: LN10Docs,
  LOG2E: LOG2EDocs,
  LOG10E: LOG10EDocs,
  NaN: NaNDocs,
  null: nullDocs,
  pi: piDocs,
  PI: piDocs,
  phi: phiDocs,
  SQRT1_2: SQRT12Docs,
  SQRT2: SQRT2Docs,
  tau: tauDocs,
  true: trueDocs,
  version: versionDocs,

  // physical constants
  // TODO: more detailed docs for physical constants
  speedOfLight: { description: 'Speed of light in vacuum', examples: ['speedOfLight'] },
  gravitationConstant: { description: 'Newtonian constant of gravitation', examples: ['gravitationConstant'] },
  planckConstant: { description: 'Planck constant', examples: ['planckConstant'] },
  reducedPlanckConstant: { description: 'Reduced Planck constant', examples: ['reducedPlanckConstant'] },

  magneticConstant: { description: 'Magnetic constant (vacuum permeability)', examples: ['magneticConstant'] },
  electricConstant: { description: 'Electric constant (vacuum permeability)', examples: ['electricConstant'] },
  vacuumImpedance: { description: 'Characteristic impedance of vacuum', examples: ['vacuumImpedance'] },
  coulomb: { description: 'Coulomb\'s constant', examples: ['coulomb'] },
  elementaryCharge: { description: 'Elementary charge', examples: ['elementaryCharge'] },
  bohrMagneton: { description: 'Borh magneton', examples: ['bohrMagneton'] },
  conductanceQuantum: { description: 'Conductance quantum', examples: ['conductanceQuantum'] },
  inverseConductanceQuantum: { description: 'Inverse conductance quantum', examples: ['inverseConductanceQuantum'] },
  // josephson: {description: 'Josephson constant', examples: ['josephson']},
  magneticFluxQuantum: { description: 'Magnetic flux quantum', examples: ['magneticFluxQuantum'] },
  nuclearMagneton: { description: 'Nuclear magneton', examples: ['nuclearMagneton'] },
  klitzing: { description: 'Von Klitzing constant', examples: ['klitzing'] },

  bohrRadius: { description: 'Borh radius', examples: ['bohrRadius'] },
  classicalElectronRadius: { description: 'Classical electron radius', examples: ['classicalElectronRadius'] },
  electronMass: { description: 'Electron mass', examples: ['electronMass'] },
  fermiCoupling: { description: 'Fermi coupling constant', examples: ['fermiCoupling'] },
  fineStructure: { description: 'Fine-structure constant', examples: ['fineStructure'] },
  hartreeEnergy: { description: 'Hartree energy', examples: ['hartreeEnergy'] },
  protonMass: { description: 'Proton mass', examples: ['protonMass'] },
  deuteronMass: { description: 'Deuteron Mass', examples: ['deuteronMass'] },
  neutronMass: { description: 'Neutron mass', examples: ['neutronMass'] },
  quantumOfCirculation: { description: 'Quantum of circulation', examples: ['quantumOfCirculation'] },
  rydberg: { description: 'Rydberg constant', examples: ['rydberg'] },
  thomsonCrossSection: { description: 'Thomson cross section', examples: ['thomsonCrossSection'] },
  weakMixingAngle: { description: 'Weak mixing angle', examples: ['weakMixingAngle'] },
  efimovFactor: { description: 'Efimov factor', examples: ['efimovFactor'] },

  atomicMass: { description: 'Atomic mass constant', examples: ['atomicMass'] },
  avogadro: { description: 'Avogadro\'s number', examples: ['avogadro'] },
  boltzmann: { description: 'Boltzmann constant', examples: ['boltzmann'] },
  faraday: { description: 'Faraday constant', examples: ['faraday'] },
  firstRadiation: { description: 'First radiation constant', examples: ['firstRadiation'] },
  loschmidt: { description: 'Loschmidt constant at T=273.15 K and p=101.325 kPa', examples: ['loschmidt'] },
  gasConstant: { description: 'Gas constant', examples: ['gasConstant'] },
  molarPlanckConstant: { description: 'Molar Planck constant', examples: ['molarPlanckConstant'] },
  molarVolume: { description: 'Molar volume of an ideal gas at T=273.15 K and p=101.325 kPa', examples: ['molarVolume'] },
  sackurTetrode: { description: 'Sackur-Tetrode constant at T=1 K and p=101.325 kPa', examples: ['sackurTetrode'] },
  secondRadiation: { description: 'Second radiation constant', examples: ['secondRadiation'] },
  stefanBoltzmann: { description: 'Stefan-Boltzmann constant', examples: ['stefanBoltzmann'] },
  wienDisplacement: { description: 'Wien displacement law constant', examples: ['wienDisplacement'] },
  // spectralRadiance: {description: 'First radiation constant for spectral radiance', examples: ['spectralRadiance']},

  molarMass: { description: 'Molar mass constant', examples: ['molarMass'] },
  molarMassC12: { description: 'Molar mass constant of carbon-12', examples: ['molarMassC12'] },
  gravity: { description: 'Standard acceleration of gravity (standard acceleration of free-fall on Earth)', examples: ['gravity'] },

  planckLength: { description: 'Planck length', examples: ['planckLength'] },
  planckMass: { description: 'Planck mass', examples: ['planckMass'] },
  planckTime: { description: 'Planck time', examples: ['planckTime'] },
  planckCharge: { description: 'Planck charge', examples: ['planckCharge'] },
  planckTemperature: { description: 'Planck temperature', examples: ['planckTemperature'] },

  // functions - algebra
  derivative: derivativeDocs,
  lsolve: lsolveDocs,
  lup: lupDocs,
  lusolve: lusolveDocs,
  simplify: simplifyDocs,
  rationalize: rationalizeDocs,
  slu: sluDocs,
  usolve: usolveDocs,
  qr: qrDocs,

  // functions - arithmetic
  abs: absDocs,
  add: addDocs,
  cbrt: cbrtDocs,
  ceil: ceilDocs,
  cube: cubeDocs,
  divide: divideDocs,
  dotDivide: dotDivideDocs,
  dotMultiply: dotMultiplyDocs,
  dotPow: dotPowDocs,
  exp: expDocs,
  expm: expmDocs,
  expm1: expm1Docs,
  fix: fixDocs,
  floor: floorDocs,
  gcd: gcdDocs,
  hypot: hypotDocs,
  lcm: lcmDocs,
  log: logDocs,
  log2: log2Docs,
  log1p: log1pDocs,
  log10: log10Docs,
  mod: modDocs,
  multiply: multiplyDocs,
  norm: normDocs,
  nthRoot: nthRootDocs,
  nthRoots: nthRootsDocs,
  pow: powDocs,
  round: roundDocs,
  sign: signDocs,
  sqrt: sqrtDocs,
  sqrtm: sqrtmDocs,
  square: squareDocs,
  subtract: subtractDocs,
  unaryMinus: unaryMinusDocs,
  unaryPlus: unaryPlusDocs,
  xgcd: xgcdDocs,

  // functions - bitwise
  bitAnd: bitAndDocs,
  bitNot: bitNotDocs,
  bitOr: bitOrDocs,
  bitXor: bitXorDocs,
  leftShift: leftShiftDocs,
  rightArithShift: rightArithShiftDocs,
  rightLogShift: rightLogShiftDocs,

  // functions - combinatorics
  bellNumbers: bellNumbersDocs,
  catalan: catalanDocs,
  composition: compositionDocs,
  stirlingS2: stirlingS2Docs,

  // functions - core
  config: configDocs,
  import: importDocs,
  typed: typedDocs,

  // functions - complex
  arg: argDocs,
  conj: conjDocs,
  re: reDocs,
  im: imDocs,

  // functions - expression
  evaluate: evaluateDocs,
  eval: evaluateDocs, // TODO: deprecated, cleanup in v7
  help: helpDocs,

  // functions - geometry
  distance: distanceDocs,
  intersect: intersectDocs,

  // functions - logical
  and: andDocs,
  not: notDocs,
  or: orDocs,
  xor: xorDocs,

  // functions - matrix
  concat: concatDocs,
  cross: crossDocs,
  column: columnDocs,
  ctranspose: ctransposeDocs,
  det: detDocs,
  diag: diagDocs,
  dot: dotDocs,
  getMatrixDataType: getMatrixDataTypeDocs,
  identity: identityDocs,
  filter: filterDocs,
  flatten: flattenDocs,
  forEach: forEachDocs,
  inv: invDocs,
  kron: kronDocs,
  map: mapDocs,
  ones: onesDocs,
  partitionSelect: partitionSelectDocs,
  range: rangeDocs,
  resize: resizeDocs,
  reshape: reshapeDocs,
  row: rowDocs,
  size: sizeDocs,
  sort: sortDocs,
  squeeze: squeezeDocs,
  subset: subsetDocs,
  trace: traceDocs,
  transpose: transposeDocs,
  zeros: zerosDocs,

  // functions - probability
  combinations: combinationsDocs,
  // distribution: distributionDocs,
  factorial: factorialDocs,
  gamma: gammaDocs,
  kldivergence: kldivergenceDocs,
  multinomial: multinomialDocs,
  permutations: permutationsDocs,
  pickRandom: pickRandomDocs,
  random: randomDocs,
  randomInt: randomIntDocs,

  // functions - relational
  compare: compareDocs,
  compareNatural: compareNaturalDocs,
  compareText: compareTextDocs,
  deepEqual: deepEqualDocs,
  equal: equalDocs,
  equalText: equalTextDocs,
  larger: largerDocs,
  largerEq: largerEqDocs,
  smaller: smallerDocs,
  smallerEq: smallerEqDocs,
  unequal: unequalDocs,

  // functions - set
  setCartesian: setCartesianDocs,
  setDifference: setDifferenceDocs,
  setDistinct: setDistinctDocs,
  setIntersect: setIntersectDocs,
  setIsSubset: setIsSubsetDocs,
  setMultiplicity: setMultiplicityDocs,
  setPowerset: setPowersetDocs,
  setSize: setSizeDocs,
  setSymDifference: setSymDifferenceDocs,
  setUnion: setUnionDocs,

  // functions - special
  erf: erfDocs,

  // functions - statistics
  mad: madDocs,
  max: maxDocs,
  mean: meanDocs,
  median: medianDocs,
  min: minDocs,
  mode: modeDocs,
  prod: prodDocs,
  quantileSeq: quantileSeqDocs,
  std: stdDocs,
  sum: sumDocs,
  variance: varianceDocs,
  var: varianceDocs, // TODO: deprecated, cleanup in v7

  // functions - trigonometry
  acos: acosDocs,
  acosh: acoshDocs,
  acot: acotDocs,
  acoth: acothDocs,
  acsc: acscDocs,
  acsch: acschDocs,
  asec: asecDocs,
  asech: asechDocs,
  asin: asinDocs,
  asinh: asinhDocs,
  atan: atanDocs,
  atanh: atanhDocs,
  atan2: atan2Docs,
  cos: cosDocs,
  cosh: coshDocs,
  cot: cotDocs,
  coth: cothDocs,
  csc: cscDocs,
  csch: cschDocs,
  sec: secDocs,
  sech: sechDocs,
  sin: sinDocs,
  sinh: sinhDocs,
  tan: tanDocs,
  tanh: tanhDocs,

  // functions - units
  to: toDocs,

  // functions - utils
  clone: cloneDocs,
  format: formatDocs,
  isNaN: isNaNDocs,
  isInteger: isIntegerDocs,
  isNegative: isNegativeDocs,
  isNumeric: isNumericDocs,
  hasNumericValue: hasNumericValueDocs,
  isPositive: isPositiveDocs,
  isPrime: isPrimeDocs,
  isZero: isZeroDocs,
  // print: printDocs // TODO: add documentation for print as soon as the parser supports objects.
  typeOf: typeOfDocs,
  typeof: typeOfDocs, // TODO: deprecated, cleanup in v7
  numeric: numericDocs
}
