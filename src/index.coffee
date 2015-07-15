_ = require 'lodash'
validator = require 'goodeggs-json-schema-validator'

module?.exports = 'validatedResource'

angular.module 'validatedResource', [
  'ngResource'
]

.factory 'validatedResource', ngInject ($resource, $window) ->

  # remove all prototype properties to get raw response object
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
            validate(queryParams, actionConfig.queryParamsSchema, "Query validation failed for action '#{actionName}'")

            resource = Resource["_#{actionName}"](params)

            resource.$promise.then (response) ->
              validate(clean(response), actionConfig.responseBodySchema, "Response body validation failed for action '#{actionName}'}")

            return resource

        else
          Resource[actionName] = (params={}, body) ->
            queryParams = getQueryParams(params, actionConfig.params, paramDefaults, actionUrl)
            validate(queryParams, actionConfig.queryParamsSchema, "Query validation failed for action '#{actionName}'")
            # TODO: what if we dont get a required field b/c of $select?
            validate(body, actionConfig.requestBodySchema, "Request body validation failed for action '#{actionName}'")

            resource = Resource["_#{actionName}"](params, body)

            resource.$promise.then (response) ->
              validate(clean(response), actionConfig.responseBodySchema, "Response body validation failed for action '#{actionName}'")

            return resource

          Resource::["$#{actionName}"] = (params={}) ->
            queryParams = getQueryParams(params, actionConfig.params, paramDefaults, actionUrl)
            validate(queryParams, actionConfig.queryParamsSchema, "Query validation failed for action '$#{actionName}'")
            validate(clean(@), actionConfig.requestBodySchema, "Request body validation failed for action '$#{actionName}'")

            promise = @["$_#{actionName}"](params)

            promise.then (response) ->
              validate(clean(response), actionConfig.responseBodySchema, "Response body validation failed for action '$#{actionName}'")

            return @

    return Resource
