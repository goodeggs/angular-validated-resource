module.exports =
  type: 'object'
  required: ['foodhubSlug']
  properties:
    foodhubSlug:
      type: 'string'
      enum: ['sfbay', 'nola', 'la', 'nyc']

    isActive:
      type: 'boolean'

    name:
      type: 'string'

