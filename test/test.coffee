# TODO: fix attaching this to window here.
window.ngInject = (arg) -> arg
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
    it 'fails if param invalid', inject (Product) ->
      # missing foodhubSlug
      expect(-> Product.query({isActive: true})).to.throw /Query validation failed/

    it 'fails if there is an extra param (for test env only)', inject (Product) ->
      # state not a valid parameter
      expect(-> Product.query({foodhubSlug: 'sfbay', state: 'lost'})).to.throw /Query validation failed/

    it 'succeeds if valid', inject (Product) ->
      expect(-> Product.query({foodhubSlug: 'sfbay', isActive: true})).not.to.throw()

  describe 'validating requestBodySchema', ->
    it 'fails if body invalid', inject (Product) ->
      # invalid from type
      expect(-> Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 27, to: 'backstock'})).to.throw /Request body validation failed/

    it 'fails if there is an extra property (for test env only)', inject (Product) ->
      # notify not expected
      expect(-> Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock', notify: true})).to.throw /Request body validation failed/

    it 'succeeds if valid', inject (Product, $httpBackend) ->
      expect(-> Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock'})).not.to.throw()

  describe 'validating responseBodySchema', ->
    it 'fails if body invalid', inject (Product, $httpBackend) ->
      $httpBackend.expectPOST('http://api.test.com/products/55a620bf8850c0bb45f323e6/move', {from: 'frontstock', to: 'backstock'})
        .respond 200,
          price: 2
          location: 'frontstock'
      fulfillRequest = ->
        Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock'})
        $httpBackend.flush()
      expect(fulfillRequest).to.throw 'Response body validation failed: \'Missing required property: name\''

    it 'fails if there is an extra property (for test env only)', inject (Product, $httpBackend) ->
      $httpBackend.expectPOST('http://api.test.com/products/55a620bf8850c0bb45f323e6/move', {from: 'frontstock', to: 'backstock'})
        .respond 200,
          name: 'cheese'
          price: 2
          location: 'frontstock'
          active: false
      fulfillRequest = ->
        Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock'})
        $httpBackend.flush()
      expect(fulfillRequest).to.throw 'Response body validation failed: \'Unknown property (not in schema)\''

    it 'succeeds if valid', inject (Product, $httpBackend) ->
      $httpBackend.expectPOST('http://api.test.com/products/55a620bf8850c0bb45f323e6/move', {from: 'frontstock', to: 'backstock'})
        .respond 200,
          name: 'cheese'
          price: 2
          location: 'frontstock'
      fulfillRequest = ->
        Product.move({_id: '55a620bf8850c0bb45f323e6'}, {from: 'frontstock', to: 'backstock'})
        $httpBackend.flush()
      expect(fulfillRequest).not.to.throw()
