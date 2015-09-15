module.exports =
  type: 'object'
  required: ['foodhubSlug', 'day']
  properties:
    foodhubSlug:
      type: 'string'
      enum: ['sfbay', 'nola', 'la', 'nyc']

    isActive:
      type: 'boolean'

    name:
      type: 'string'

    day:
      type: 'string'
      format: 'date'

