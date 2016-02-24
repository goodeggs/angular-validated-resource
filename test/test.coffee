# TODO: fix attaching this to window here.
geomoment = require 'geomoment'
require 'angular-resource'

describe 'validatedResource', ->
  beforeEach ->
    angular.mock.module(require('./product.coffee'))
    angular.mock.module ($provide) ->
      $provide.constant '$window',
        settings: { env: 'test' }
        document: window.document
      null # https://groups.google.com/forum/#!msg/angular/gCGF_B4eQkc/XjkvbgE9iMcJ

  describe 'validating queryParamsSchema', ->
    describe 'class method', ->
      it 'fails if param invalid', inject (Product) ->
        expect(-> Product.query({isActive: true})).to.throw 'Query validation failed for action \'query\': Missing required property: foodhubSlug'

      it 'fails if there is an extra param (for test env only)', inject (Product) ->
        expect(-> Product.query({foodhubSlug: 'sfbay', state: 'lost'})).to.throw 'Query validation failed for action \'query\': Unknown property (not in schema) at /state'

      it 'succeeds if valid', inject (Product, $httpBackend) ->
        geomoment.stubTime '2015-11-11 09:00:00'
        $httpBackend.expectGET('http://api.test.com/products?day=2015-11-11&foodhubSlug=sfbay&isActive=true')
          .respond 200, [{_id: '55a620bf8850c0bb45f323e6', name: 'apple'}]
        # undefined fields should be stripped first...
        expect(-> Product.query({foodhubSlug: 'sfbay', isActive: true, randomField: undefined}).$promise.then(->)).not.to.throw()
        $httpBackend.flush()
        geomoment.restoreTime()

      it 'does not include @ url params if not in body', inject (Product, $httpBackend) ->
        $httpBackend.expectPOST('http://api.test.com/products/generate').respond 200, {_id: '55a620bf8850c0bb45f323e6', name: 'apple'}
        expect(-> Product.generate().$promise.then(->)).not.to.throw()
        $httpBackend.flush()

      it 'does include @ url params if in body', inject (Product, $httpBackend) ->
        $httpBackend.expectPOST('http://api.test.com/products/generate?name=apple').respond 200, {_id: '55a620bf8850c0bb45f323e6', name: 'apple'}
        expect(-> Product.generate({}, {name: 'apple'}).$promise.then(->)).not.to.throw()
        $httpBackend.flush()

    describe 'instance method', ->
      beforeEach inject (Product) ->
        @product = new Product({_id: '55a620bf8850c0bb45f323e6', name: 'apple'})

      it 'fails if param invalid', inject (Product) ->
        expect(=> @product.$update({$select: true})).to.throw 'Query validation failed for action \'$update\': Invalid type: boolean (expected string) at /$select'

      it 'fails if there is an extra param (for test env only)', inject (Product) ->
        expect(=> @product.$update({$select: 'name', deactivate: true})).to.throw 'Query validation failed for action \'$update\': Unknown property (not in schema) at /deactivate'

      it 'succeeds if valid', inject (Product, $httpBackend) ->
        $httpBackend.expectPUT('http://api.test.com/products/55a620bf8850c0bb45f323e6?$select=name')
          .respond 200, {_id: '55a620bf8850c0bb45f323e6', name: 'apple'}
        # should still return a promise
        expect(=> @product.$update({$select: 'name'}).then(->)).not.to.throw()
        $httpBackend.flush()

  describe 'validating requestBodySchema', ->
    describe 'class method', ->
      it 'fails if body invalid', inject (Product) ->
        expect(-> Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 27, to: 'backstock'})).to.throw 'Request body validation failed for action \'move\': Invalid type: number (expected string) at /from'

      it 'fails if there is an extra property (for test env only)', inject (Product) ->
        expect(-> Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock', notify: true})).to.throw 'Request body validation failed for action \'move\': Unknown property (not in schema) at /notify'

      it 'succeeds if valid (for class method)', inject (Product, $httpBackend) ->
        $httpBackend.expectPOST('http://api.test.com/products/55a620bf8850c0bb45f323e6/move', {from: 'frontstock', to: 'backstock'})
          .respond 200, {_id: '55a620bf8850c0bb45f323e6', name: 'apple'}
        expect(-> Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock'}).$promise.then(->)).not.to.throw()
        $httpBackend.flush()

    describe 'instance method', ->
      it 'fails if param invalid', inject (Product) ->
        product = new Product({_id: '123', name: 'apple'})
        expect(=> product.$update()).to.throw 'Request body validation failed for action \'$update\': Format validation failed (objectid expected) at /_id'

      it 'fails if there is an extra param (for test env only)', inject (Product) ->
        product = new Product({_id: '55a620bf8850c0bb45f323e6', name: 'apple', active: true})
        expect(=> product.$update()).to.throw 'Request body validation failed for action \'$update\': Unknown property (not in schema) at /active'

      it 'succeeds if valid', inject (Product, $httpBackend) ->
        $httpBackend.expectPUT('http://api.test.com/products/55a620bf8850c0bb45f323e6')
          .respond 200, {_id: '55a620bf8850c0bb45f323e6', name: 'apple'}
        product = new Product({_id: '55a620bf8850c0bb45f323e6', name: 'apple'})
        expect(=> product.$update().then(->)).not.to.throw()
        $httpBackend.flush()

  describe 'validating responseBodySchema', ->
    describe 'class method', ->
      it 'fails if body invalid', inject (Product, $httpBackend) ->
        $httpBackend.expectPOST('http://api.test.com/products/55a620bf8850c0bb45f323e6/move', {from: 'frontstock', to: 'backstock'})
          .respond 200, {name: 'apple'}
        fulfillRequest = ->
          Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock'})
          $httpBackend.flush()
        expect(fulfillRequest).to.throw 'Response body validation failed for action \'move\': Missing required property: _id'

      it 'fails if there is an extra property (for test env only)', inject (Product, $httpBackend) ->
        $httpBackend.expectPOST('http://api.test.com/products/55a620bf8850c0bb45f323e6/move', {from: 'frontstock', to: 'backstock'})
          .respond 200,
            _id: '55a620bf8850c0bb45f323e6'
            name: 'cheese'
            price: 2
            location: 'frontstock'
            active: false
        fulfillRequest = ->
          Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock'})
          $httpBackend.flush()
        expect(fulfillRequest).to.throw 'Response body validation failed for action \'move\': Unknown property (not in schema) at /active'

      it 'succeeds if valid (for class method)', inject (Product, $httpBackend) ->
        $httpBackend.expectPOST('http://api.test.com/products/55a620bf8850c0bb45f323e6/move', {from: 'frontstock', to: 'backstock'})
          .respond 200,
            _id: '55a620bf8850c0bb45f323e6'
            name: 'cheese'
        fulfillRequest = ->
          Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock'}).$promise.then(->)
          $httpBackend.flush()
        expect(fulfillRequest).not.to.throw()

    describe 'instance method', ->
      it 'fails if body invalid', inject (Product, $httpBackend) ->
        $httpBackend.expectPUT('http://api.test.com/products/55a620bf8850c0bb45f323e6')
          .respond 200, {_id: '55a620bf8850c0bb45f323e6'}
        fulfillRequest = ->
          product = new Product({_id: '55a620bf8850c0bb45f323e6', name: 'apple'})
          product.$update()
          $httpBackend.flush()
        expect(fulfillRequest).to.throw 'Response body validation failed for action \'$update\': Missing required property: name'

      it 'fails if there is an extra property (for test env only)', inject (Product, $httpBackend) ->
        $httpBackend.expectPUT('http://api.test.com/products/55a620bf8850c0bb45f323e6')
          .respond 200, {_id: '55a620bf8850c0bb45f323e6', name: 'apple', active: true}
        fulfillRequest = ->
          product = new Product({_id: '55a620bf8850c0bb45f323e6', name: 'apple'})
          product.$update()
          $httpBackend.flush()
        expect(fulfillRequest).to.throw 'Response body validation failed for action \'$update\': Unknown property (not in schema) at /active'

      it 'succeeds if valid', inject (Product, $httpBackend) ->
        $httpBackend.expectPUT('http://api.test.com/products/55a620bf8850c0bb45f323e6')
          .respond 200, {_id: '55a620bf8850c0bb45f323e6', name: 'apple'}
        fulfillInstanceRequest = ->
          product = new Product({_id: '55a620bf8850c0bb45f323e6', name: 'apple'})
          product.$update().then(->)
          $httpBackend.flush()
        expect(fulfillInstanceRequest).not.to.throw()
