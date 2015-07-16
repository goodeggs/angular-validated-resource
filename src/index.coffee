_ = require 'lodash'
validator = require 'goodeggs-json-schema-validator'

module?.exports = 'validatedResource'

angular.module 'validatedResource', [
  'ngResource'
]

.factory 'validatedResource', ngInject ($resource, $window) ->

  # remove all prototype properties, and undefined fields
  clean = (resource) ->
    JSON.parse JSON.stringify resource


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
      message = "#{errorPrefix}: #{validator.error.message}"
      message += " at #{validator.error.dataPath}" if validator.error.dataPath?.length
      throw new Error message

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
          Resource[actionName] = (params={}, success, error) ->

            queryParams = getQueryParams(params, actionConfig.params, paramDefaults, actionUrl)
            validate(clean(queryParams), actionConfig.queryParamsSchema, "Query validation failed for action '#{actionName}'")

            resource = Resource["_#{actionName}"](params, success, error)

            resource.$promise.then (response) ->
              validate(clean(response), actionConfig.responseBodySchema, "Response body validation failed for action '#{actionName}'}")

            return resource

        else
          Resource[actionName] = (params={}, body, success, error) ->
            queryParams = getQueryParams(params, actionConfig.params, paramDefaults, actionUrl)
            validate(clean(queryParams), actionConfig.queryParamsSchema, "Query validation failed for action '#{actionName}'")
            # TODO: what if we dont get a required field b/c of $select?
            validate(clean(body), actionConfig.requestBodySchema, "Request body validation failed for action '#{actionName}'")

            resource = Resource["_#{actionName}"](params, body, success, error)

            resource.$promise.then (response) ->
              validate(clean(response), actionConfig.responseBodySchema, "Response body validation failed for action '#{actionName}'")

            return resource

          Resource::["$#{actionName}"] = (params={}, success, error) ->
            queryParams = getQueryParams(params, actionConfig.params, paramDefaults, actionUrl)
            validate(clean(queryParams), actionConfig.queryParamsSchema, "Query validation failed for action '$#{actionName}'")
            validate(clean(@), actionConfig.requestBodySchema, "Request body validation failed for action '$#{actionName}'")

            promise = @["$_#{actionName}"](params, success, error)

            promise.then (response) ->
              validate(clean(response), actionConfig.responseBodySchema, "Response body validation failed for action '$#{actionName}'")

            return promise

    return Resource
