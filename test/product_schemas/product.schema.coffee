module.exports =
  type: 'object'
  required: ['_id', 'name']
  properties:
    _id:
      type: 'string'
      format: 'objectid'
    name:
      type: 'string'
    price:
      type: 'number'
    location:
      type: 'string'
