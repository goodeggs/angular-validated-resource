# Angular Validated Resource

JSON Schema validation for angular resource.

[![build status][travis-badge]][travis-link]
[![npm version][npm-badge]][npm-link]
[![MIT license][license-badge]][license-link]
[![we're hiring][hiring-badge]][hiring-link]


## Usage

```
npm install angular-validated-resource
```

Designed to be an (almost) drop-in replacement for angular resource. When you configure the resource actions, additionally pass a schema to `queryParamsSchema`, `requestBodySchema`, or `responseBodySchema` to automatically validate on every request.

```coffee
angular.module 'Product', [
  require 'angular-validated-resource'
]

.factory 'Product', ngInject (validatedResource) ->
  validatedResource 'http://api.test.com/products/:_id', {_id: '@_id'},
    query:
      method: 'GET'
      isArray: true
      queryParamsSchema: require './product_schemas/query/query_params.json'
      requestBodySchema: require './product_schemas/query/request_body.json'
      responseBodySchema: require './product_schemas/query/response_body.json'
    move:
      method: 'POST'
      url: 'http://api.test.com/products/:_id/move'
      queryParamsSchema: require './product_schemas/move/query_params.json'
      requestBodySchema: require './product_schemas/move/request_body.json'
      responseBodySchema: require './product_schemas/move/response_body.json'
```

If window.env is 'test', validation **will not** allow unknown fields. Otherwise, validation **will** allow unknown fields.

Although not required, we strongly recommended that you validate all parts of the request (queryParams, requestBody, and responseBody) for every action, even if the validation is just checking for an empty object. This way, you will catch any unexpected data that you pass through.

## Contributing

Please follow our [Code of Conduct](https://github.com/goodeggs/angular-validated-resource/blob/master/CODE_OF_CONDUCT.md)
when contributing to this project.

```
$ git clone https://github.com/goodeggs/angular-validated-resource && cd angular-validated-resource
$ npm install
$ npm test
```

_Module scaffold generated by [generator-goodeggs-npm](https://github.com/goodeggs/generator-goodeggs-npm)._


[travis-badge]: http://img.shields.io/travis/goodeggs/angular-validated-resource.svg?style=flat-square
[travis-link]: https://travis-ci.org/goodeggs/angular-validated-resource
[npm-badge]: http://img.shields.io/npm/v/angular-validated-resource.svg?style=flat-square
[npm-link]: https://www.npmjs.org/package/angular-validated-resource
[license-badge]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license-link]: LICENSE.md
[hiring-badge]: https://img.shields.io/badge/we're_hiring-yes-brightgreen.svg?style=flat-square
[hiring-link]: http://goodeggs.jobscore.com/?detail=Open+Source&sid=161
