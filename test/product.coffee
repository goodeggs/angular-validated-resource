module.exports = __filename

angular.module __filename, [
  require('../src')
]

.factory 'Product', ngInject (validatedResource) ->
  validatedResource 'http://api.test.com/products/:_id', {_id: '@_id'},
    query:
      method: 'GET'
      isArray: true
      queryParamsSchema: require './product_schemas/query/query_params'
      responseBodySchema: require './product_schemas/query/response_body'
    move:
      method: 'POST'
      url: 'http://api.test.com/products/:_id/move'
      params: {_id: '@_id'}
      requestBodySchema: require './product_schemas/move/request_body'
      responseBodySchema: require './product_schemas/move/response_body'

