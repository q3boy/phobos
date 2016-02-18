fs = require 'fs'
http = require 'http'
lodash = require 'lodash'
fsutil = require 'nodejs-fs-utils'
path = require 'path'
{parse: urlParse} = require 'url'
{os} = require 'mars-deimos'
response = require './response'
chalk = require 'chalk'

class Phobos
  constructor : (opt) ->
    @cwd = process.cwd()
    @rewrite = []
    @initOptions(opt).parseDir().parseRewrite()
    @response = response @options.vars, locale_data: @options.locale_data, locale : @options.locale

  initOptions : (opt)->
    options = dir : 'phobos', locale : 'zh_CN', locale_data : {}, rewrite : [], vars : {}
    rc = path.join @cwd, '.phobosrc'
    if fs.existsSync rc
      try
        rcOptions = require rc
      catch e
        console.error "[#{chalk.bold.red 'phobos rcfile parse fail'}] " +
          "\"#{rc}\" #{chalk.gray e.message}"
      options = os options, rcOptions
    @options = os options, opt
    @

  parseRewrite : ->
    for rule in @options.rewrite
      if 'string' is typeof rule.test
        rule = lodash.clone rule
        rule.test = new RegExp "^#{rule.test.replace /\*/g, '(.*)'}$"
      @rewrite.push rule
    @


  parseDir : ->
    @api = {}
    dir = path.join @cwd, @options.dir unless @options.dir[0] is '/'
    return @ unless fs.existsSync dir
    fsutil.walkSync dir, skipErrors : true, (err, file, stats, next, cache) =>
      # return unless next? # all done
      return next() if stats.isDirectory() # skip when is dir
      return next() unless '.json' is path.extname file # skip when not a json file
      try
        json = fs.readFileSync(file).toString()
        file = path.relative dir, file
        url = file.substring 0, file.length - 5
        data = JSON.parse json
      catch e
        console.warn "[#{chalk.bold.yellow 'phobos define-file parse fail'}] " +
          "\"#{path.join @options.dir, file}\" #{chalk.gray e.message}"
      if data is undefined
        next()
      else if (method = path.basename url) in ['get', 'post', 'delete', 'put']
        @api["#{path.dirname url}@#{method}"] = data
      else
        @api["#{url}@all"] = data
      next()
    @

  middleware : ->
    mw = (req, resp, next) =>
      method = req.method.toLowerCase()
      if urlRewrite = @routerRewrite req.url, method
        req.ordinaryUrl = url
        req.url = url = urlRewrite
      {path: url, query} = urlParse req.url
      return if @routerProxy req, resp, next
      return unless (data = @routerApi url, method)?
      resp.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
      resp.end JSON.stringify @response.trans data, "#{url}@#{method}", query
      return
    mw.phobos = @
    mw

  routerApi : (url, method) ->
    {pathname} = urlParse url
    pathname = pathname.replace /^\/+/g, ''
    all = @api["#{pathname}@all"]
    method = @api["#{pathname}@#{method.toLowerCase()}"]
    method or all

  routerRewrite : (url, reqMethod) ->
    for {test, target, method} in @rewrite
      method = method or 'all'
      if (method is 'all' or reqMethod is method) and test.test url
        return url.replace test, target

  routerProxy : (req, resp, next) ->
    return next() unless /^http:\/\/.+/.test req.url
    req.pause()
    options = urlParse req.url
    req.url = req.ordinaryUrl
    options.headers = {}
    options.headers[k] = v for k,v of req.headers when k isnt 'host'
    options.method = req.method
    options.agent = false
    conn = http.request options, (serverResp)->
      serverResp.pause()
      resp.writeHead serverResp.statusCode, serverResp.headers
      serverResp.pipe resp
      serverResp.resume()
    req.pipe conn
    req.resume()
    return true

module.exports = (opt) -> new Phobos(opt).middleware()
module.exports.Phobos = Phobos
