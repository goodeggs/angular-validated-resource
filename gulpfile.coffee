path = require 'path'
karma = require 'goodeggs-karma'

gulp = require 'gulp'

gulp.task 'test', [
  'test:karma'
]

gulp.task 'test:karma', (done) ->
  process.env.NODE_ENV = 'test'
  karma.run({
    files: [
      path.join(require.resolve('angular'), '..', 'angular.js')
      path.join(require.resolve('angular-mocks'))

      'test/*test.coffee'
    ]
    singleRun: true
  }, done)
