{assert} = require 'art-foundation/src/art/dev_tools/test/art_chai'
{Math} = require 'art-foundation'

# 'lib/art'
# point = Art.Atomic.Point.point
# rect = Art.Atomic.Rectangle.rect
# Rectangle = Art.Atomic.Rectangle

suite "Art.Foundation.Math", ->
  test "floatEq", ->
    smallestDifferent = 1 + Math.float64Precision
    largestSame = 1 + Math.float64Precision/2
    assert.ok 1 != largestSame
    assert.ok 1 != smallestDifferent

    assert.equal true, Math.floatEq(1, largestSame)
    assert.equal false, Math.floatEq(1, smallestDifferent)

  test "modulo", ->
    assert.eq Math.modulo(1.25, 1), 0.25
    assert.eq Math.modulo(5, 3), 2

    assert.eq Math.modulo(4.25, 1), 0.25
    assert.eq Math.modulo(11, 3), 2

  test "modulo of negative numbers should be positive", ->
    assert.eq Math.modulo(-1.25, 1), 0.75
    assert.eq Math.modulo(-5, 3), 1

    assert.eq Math.modulo(-4.25, 1), 0.75
    assert.eq Math.modulo(-11, 3), 1

  test "float32Eq", ->
    smallestDifferent = 1 + Math.float32Precision
    largestSame = 1 + Math.float32Precision/2
    assert.ok 1 != largestSame
    assert.ok 1 != smallestDifferent

    assert.equal true, Math.float32Eq(1, largestSame)
    assert.equal false, Math.float32Eq(1, smallestDifferent)

  test "floatEq and Infinity", ->
    assert.equal true, Math.floatEq Infinity, Infinity
    assert.equal false, Math.floatEq Infinity, 1
    assert.equal false, Math.floatEq 1, Infinity

  test "float32Eq and Infinity", ->
    assert.equal true, Math.float32Eq Infinity, Infinity
    assert.equal false, Math.float32Eq Infinity, 1
    assert.equal false, Math.float32Eq 1, Infinity

  test "float32Eq0", ->
    assert.equal true, Math.float32Eq0 0
    assert.equal false, Math.float32Eq0 1
    assert.equal false, Math.float32Eq0 -1

  test "floatEq0", ->
    assert.equal true,  Math.floatEq0 0
    assert.equal false, Math.floatEq0 1
    assert.equal false, Math.floatEq0 -1

  test "intRand", ->
    for i in [0..1000]
      v = Math.intRand 10
      assert.ok typeof v is "number"
      assert.eq v | 0, v
      assert.ok v >= 0
      assert.ok v < 10
