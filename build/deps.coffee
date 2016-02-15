path  = require 'path'
madge = require 'madge'
gs    = require 'glob-stream'

class DepsTree
  constructor: (dirs, specs, cb, @dir=process.cwd()) ->
    @dirs = (path.relative(@dir, d) for d in dirs)
    @specs = []
    @tree = {}
    gs.create(specs, cwd:@dir)
    .on 'data', (file)=>
      @specs.push path.relative file.cwd, file.path
    .on 'end', =>
      @analysis()
      cb.call @

  analysis : ->
    @tree = {}
    for file, deps of madge(@dirs, exclude:/\bnode_modules\/|^\w+$/).tree
      @tree[file] = (path.relative(@dir, path.join(path.dirname(file), d)) for d in deps) if deps and deps.length
    for file, list of @tree
      @tree[file] = @fetch file

  fetch : (file, list=[]) ->
    for f in @tree[file]
      if f not in list
        list.push f
        if @tree[f] and @tree[f].length > 0
          list.push f1 for f1 in @fetch f, list when f1 not in list
    list

  find : (file) ->
    file = file.substr(0, file.length - path.extname(file).length)
    file = path.relative @dir, file
    list = []
    for spec, deps of @tree
      if spec is file
        list.push spec
        continue
      for dep in deps
        if dep is file
          list.push spec
          break
    res = []
    for f in list
      res.push spec for spec in @specs when 0 is spec.indexOf f+'.'
    res
# new DepsTree ['./lib', './spec'], ['spec/**/spec-*.coffee'], ->
#   console.log @find '/Users/q3boy/codes/epub-builder/spec/spec-util.coffee'

module.exports = (dirs, specs, cb, dir)->
  new DepsTree dirs, specs, cb, dir
