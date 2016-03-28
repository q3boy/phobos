fs = require 'fs'
http = require 'http'
lodash = require 'lodash'
fsutil = require 'nodejs-fs-utils'
path = require 'path'
{parse: urlParse} = require 'url'
{parse: queryParse} = require 'querystring'
{os} = require 'mars-deimos'
response = require './response'
chalk = require 'chalk'

class Phobos
  constructor : (opt) ->
    @cwd = process.cwd()
    @rewrite = []
    @initOptions(opt).parseRewrite()
    @dir = path.join @cwd, @options.dir unless @options.dir[0] is '/'
    @response = response @options.vars, locale_data: @options.locale_data, locale : @options.locale

  initOptions : (opt)->
    options = dir : 'phobos', locale : 'zh_CN', locale_data : {}, rewrite : [], vars : {}
    rc = path.join @cwd, '.phobosrc'
    if fs.existsSync rc
      try
        rcOptions = require rc
      catch e
        console.error "[#{chalk.bold.red 'phobos rcfile parse fail'}] " +
          "\"#{path.relative @cwd, rc}\" #{chalk.gray e.message}"
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

  middleware : ->

    mw = (req, resp, next) =>
      method = req.method.toUpperCase()

      run = (post)=>
        url = req.url
        if urlRewrite = @routerRewrite req.url, method
          if  /^http:\/\/.+/.test req.url
            req.proxyToUrl = urlRewrite
          else
            req.ordinaryUrl = url
            req.url = url = urlRewrite
        # {path: url} = urlParse req.url, true
        return next() if @routerProxy req, resp, next
        return next() unless (data = @routerApi url, method)?
        resp.writeHead 200, 'Content-Type': 'application/json; charset=utf-8'
        resp.end JSON.stringify @response.trans data, req.url, post
        return

      if method is 'POST' or method is 'PUT'
        chunks = []
        req.on 'data', (chunk) -> chunks.push(chunk)
        req.on 'end', ->
          raw = Buffer.concat(chunks).toString()
          post = {}
          try
            post = JSON.parse raw
          catch e
            post = queryParse raw
          run post
      else
        run {}
    mw.phobos = @
    mw

  routerApi : (url, method) ->
    # check method
    method = method.toLowerCase()
    return unless method in ['get', 'post', 'put', 'delete']

    # get filepath
    {pathname} = urlParse url
    pathname = pathname.replace /^\/+/g, ''

    # check file
    fileMethod = path.join @dir, pathname, "#{method.toLowerCase()}.json"
    fileAll = path.join @dir, "#{pathname}.json"
    if fs.existsSync fileMethod
      file = fileMethod
    else if fs.existsSync fileAll
      file = fileAll
    else
      return
    try
      json = fs.readFileSync(file).toString()
      file = path.relative @cwd, file
      data = JSON.parse json
    catch e
      console.warn "[#{chalk.bold.yellow 'phobos define-file parse fail'}] " +
        "\"#{file}\" #{chalk.gray e.message}"
    return data

  routerRewrite : (url, reqMethod) ->
    for {test, target, method} in @rewrite
      method = method or 'all'
      if (method is 'all' or reqMethod is method) and test.test url
        return url.replace test, target

  routerProxy : (req, resp, next) ->
    return unless req.proxyToUrl
    # return next() unless /^http:\/\/.+/.test req.url
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
