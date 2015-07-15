_ = require 'lodash'
validator = require 'goodeggs-json-schema-validator'

module?.exports = 'validatedResource'

angular.module 'validatedResource', [
  'ngResource'
]

.factory 'validatedResource', ngInject ($resource, $window) ->
  getUrlParams = (url) ->
    regex = /\/:(\w*)/g
    matches = []
    match = regex.exec(url)
    while match?
      matches.push(match[1])
      match = regex.exec(url)
    matches

  getQueryParams = (params, actionParams, paramDefaults, url) ->
    allParams = _.assign({}, paramDefaults, actionParams, params)
    _.omit(allParams, getUrlParams(url))

  validate = (obj, schema, errorPrefix) ->
    banUnknownProperties = true if $window.settings?.env is 'test'
    if schema? and not validator.validate(obj, schema, null, banUnknownProperties)
      throw new Error "#{errorPrefix}: '#{validator.error.message}'"

  (url, paramDefaults, actions) ->
    privateActions = do ->
      result = {}
      for actionName, actionConfig of actions
        result["_#{actionName}"] = actionConfig
      result

    Resource = $resource(url, paramDefaults, privateActions)

    # wrap all actions with validation
    for actionName, actionConfig of actions

      do (actionName, actionConfig) ->
        actionUrl = actionConfig.url or url

        if actionConfig.method is 'GET'
          Resource[actionName] = (params={}) ->

            queryParams = getQueryParams(params, actionConfig.params, paramDefaults, actionUrl)
            validate(queryParams, actionConfig.queryParamsSchema, 'Query validation failed')

            resource = Resource["_#{actionName}"](params)

            resource.$promise.then (response) ->
              cleanedResponse = JSON.parse(JSON.stringify(response)) # remove angular properties for validation
              validate(response, actionConfig.responseBodySchema, 'Response body validation failed')

            return resource

        else
          Resource[actionName] = (params={}, body) ->
            queryParams = getQueryParams(params, actionConfig.params, paramDefaults, actionUrl)
            validate(queryParams, actionConfig.queryParamsSchema, 'Query validation failed')
            validate(body, actionConfig.requestBodySchema, 'Request body validation failed')

            resource = Resource["_#{actionName}"](params, body)

            resource.$promise.then (response) ->
              cleanedResponse = JSON.parse(JSON.stringify(response)) # remove angular properties for validation
              validate(cleanedResponse, actionConfig.responseBodySchema, 'Response body validation failed')

            return resource

          Resource::[actionName] = (params={}) ->
            queryParams = getQueryParams(params, actionConfig.params, paramDefaults, actionUrl)
            validate(queryParams, actionConfig.queryParamsSchema, 'Query validation failed')
            validate(body, @, 'Request body validation failed')

            resource = @["_#{actionName}"](params)

            resource.$promise.then (response) ->
              cleanedResponse = JSON.parse(JSON.stringify(response)) # remove angular properties for validation
              validate(response, actionConfig.responseBodySchema, 'Response body validation failed')

            return resource

    return Resource
