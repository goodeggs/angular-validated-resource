geomoment = require 'geomoment'
module.exports = __filename

angular.module __filename, [
  require('../src')
]

.factory 'Product', ['validatedResource', (validatedResource) ->
  validatedResource 'http://api.test.com/products/:_id', {_id: '@_id'},
    query:
      method: 'GET'
      isArray: true
      params:
        day: -> geomoment().dayString()
      queryParamsSchema: require './product_schemas/query/query_params'
      requestBodySchema: require './product_schemas/query/request_body'
      responseBodySchema: require './product_schemas/query/response_body'
    update:
      method: 'PUT'
      queryParamsSchema: require './product_schemas/update/query_params'
      requestBodySchema: require './product_schemas/update/request_body'
      responseBodySchema: require './product_schemas/update/response_body'
    move:
      method: 'POST'
      url: 'http://api.test.com/products/:_id/move'
      params:
        _id: '@_id'
      queryParamsSchema: require './product_schemas/move/query_params'
      requestBodySchema: require './product_schemas/move/request_body'
      responseBodySchema: require './product_schemas/move/response_body'
    generate:
      method: 'POST'
      url: 'http://api.test.com/products/generate'
      params: {name: '@name'}
      queryParamsSchema: require './product_schemas/generate/query_params'
      requestBodySchema: require './product_schemas/generate/request_body'
      responseBodySchema: require './product_schemas/generate/response_body'
]
