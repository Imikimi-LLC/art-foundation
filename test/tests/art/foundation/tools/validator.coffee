Foundation = Neptune.Art.Foundation
{Validator, isString, log, findEmailRegexp} = Foundation

module.exports = suite:
  new: ->
    test "new Validator", ->
      new Validator

  exclusive: ->
    test "exclusive", ->
      v = new Validator {id: 'trimmedString'}, exclusive: true
      v.preCreate id: "hi"
      .then -> assert.rejects v.preCreate id: "id", foo: "bar"

    test "inclusive", ->
      v = new Validator id: 'trimmedString'
      v.preCreate id: "hi"
      .then -> v.preCreate id: "id", foo: "bar"

  trimmedString: ->
    test "id: 'trimmedString'", ->
      v = new Validator id: 'trimmedString'
      v.preCreate id: "ok"
      .then -> v.preCreate {}
      .then -> assert.rejects v.preCreate id: 123

    test "required: 'trimmedString'", ->
      v = new Validator id: required: 'trimmedString'
      assert.rejects v.preCreate id: 123
      .then -> assert.rejects v.preCreate()

    test "requiredPresent: 'trimmedString'", ->
      v = new Validator id: requiredPresent: 'trimmedString'
      assert.rejects v.preCreate(id: 123), "with number"
      .then -> assert.rejects v.preCreate(), "missing"
      .then -> assert.rejects v.preCreate(id: ""), "id:''"
      .then -> assert.rejects v.preCreate(id: "  "), "id:'  '"
      .then -> v.preCreate id: "hi"

  declarationTypes: ->
    test "fieldType: 'id'", ->
      v = new Validator
        id: fieldType: "id"

      assert.rejects v.preCreate {}
      .then -> v.preUpdate {}
      .then -> v.preCreate id: "123"
      .then ->
        assert.rejects v.preCreate(id: 123)
        .then (v) ->
          assert.eq v,
            validationFailure:       "preCreate: fields invalid"
            invalidFields: id: 123

    test "validate: ->", ->
      v = new Validator
        id: validate: (v) -> isString v

      v.preCreate {}
      .then -> v.preUpdate {}
      .then -> v.preCreate id: "123"
      .then ->
        assert.rejects v.preCreate id: 123
        .then (rejection) ->
          assert.eq rejection,
            validationFailure:       "preCreate: fields invalid"
            invalidFields: id: 123

    test "preprocess: ->", ->
      v = new Validator
        id: preprocess: (v) -> "#{v}a"

      Promise.resolve()
      .then ->
        v.preUpdate id: "123"
        .then ({id}) -> assert.eq id, "123a"

      .then ->
        v.preUpdate id: 456
        .then ({id}) -> assert.eq id, "456a"

    test "required: true", ->
      v = new Validator
        id: required: true

      v.preCreate id: 123
      .then -> assert.rejects v.preCreate id: null
      .then (rejection) ->
        assert.eq rejection,
          validationFailure: "preCreate: fields missing"
          missingFields: id: null

      .then -> assert.rejects v.preCreate id: undefined
      .then (rejection) ->
        assert.eq rejection,
          validationFailure: "preCreate: fields missing"
          missingFields: id: undefined

      .then -> assert.rejects v.preCreate {}
      .then (rejection) ->
        assert.eq rejection,
        validationFailure: "preCreate: fields missing"
        missingFields: id: undefined

      .then -> v.preCreate id: false
      .then -> v.preUpdate id: null
      .then -> v.preUpdate id: 123

    test "instanceof: Foo", ->
      class Foo
      class Bar extends Foo
      v = new Validator
        foo: instanceof: Foo

      log null_instanceof: null instanceof Foo

      Promise.resolve()
      .then -> v.preCreate foo: new Foo
      .then -> v.preCreate foo: new Bar
      .then -> v.preCreate foo: null
      .then ->
        assert.rejects v.preCreate foo: {}
      .then (rejection) ->
        assert.eq rejection,
          validationFailure:       "preCreate: fields invalid"
          invalidFields: foo: {}

  compoundTests:->
    test "require: validate: ->", ->
      v = new Validator
        foo: required: validate: (v) -> v.match ///^email\:#{findEmailRegexp.source}$///

      assert.rejects v.preCreate id: 123
      .then -> assert.rejects v.preCreate foo: "test@test.com"
      .then -> assert.rejects v.preCreate foo: "email:me@test"
      .then ->
        assert.rejects v.preCreate foo: "email:me"
      .then (rejection) ->
        assert.eq rejection,
          validationFailure:       "preCreate: fields invalid"
          invalidFields: foo: "email:me"

      .then ->
        assert.rejects v.preUpdate foo: "email:me"
      .then (rejection) ->
        assert.eq rejection,
          validationFailure:       "preUpdate: fields invalid"
          invalidFields: foo: "email:me"

      .then -> v.preUpdate()
      .then -> v.preCreate foo: "email:me@test.com"
      .then -> v.preUpdate foo: "email:me@test.com"

