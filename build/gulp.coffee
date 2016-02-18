gulp     = require 'gulp'
util     = require 'gulp-util'
mocha    = require 'gulp-mocha'
istanbul = require 'gulp-istanbul'
coffee   = require 'gulp-coffee'
seq      = require 'gulp-sequence'
noti     = require 'mocha-notifier-reporter'
futil    = require 'nodejs-fs-utils'
fs       = require 'fs'
os       = require 'os'
cp       = require 'child_process'
deps     = require './deps'



cs    = ['lib/**/*.coffee']
js    = ["lib/**/*.js"]
tests = ['tests/**/test-*.coffee']
clean = ['coverage', 'dist']

wfiles = js.concat(cs).concat(tests)


# coverVar = '$$cov_istan_vars'

gulp.task 'clean',  -> futil.rmdirsSync dir for dir in clean when fs.existsSync dir

gulp.task 'test', (done)->
  task = gulp.src tests, read: false
  .pipe mocha reporter: noti.decorate 'tap'

gulp.task 'coffee', ['clean'], ->
  gulp.src ['./lib/**/*.coffee', './tests/**/test-*.coffee'], {base: './'}
    .pipe coffee bare: true
    .on 'error', util.log
    .pipe gulp.dest './dist/'

gulp.task 'publish', ['coffee'], ->
  futil.copySync 'tests/def', 'dist/tests/def', (err) ->
    throw err if err
  gulp.src './dist/tests/**/test-*.js', read: false
    .pipe mocha reporter: noti.decorate 'tap'


gulp.task 'cover', ['coffee'], ->
  futil.copySync 'tests/def', 'dist/tests/def', (err) ->
    throw err if err
  gulp.src './dist/lib/**/*.js'
    .pipe istanbul()
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src './dist/tests/**/test-*.js'
        .pipe mocha()
        .pipe istanbul.writeReports()
        .pipe istanbul.enforceThresholds {thresholds: {global: 90}}
        .on 'finish', ->
          switch os.platform()
            when 'darwin'
              cp.exec 'open coverage/lcov-report/index.html'


gulp.task 'default', ['test']

gulp.task 'watch', -> gulp.watch wfiles, (evt)->
  if evt.type is 'changed'
    deps ['./lib', './tests'], tests, ->
      gulp.src @find(evt.path), read: false
      .pipe mocha reporter: noti.decorate 'tap'
      .on 'error', (err)->
        util.log err.message
    return
  gulp.src tests, read: false
  .pipe mocha reporter: noti.decorate 'tap'


gulp.task 'dev', ['test', 'watch']
