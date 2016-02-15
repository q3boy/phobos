{expect:e} = require 'chai'
phobos = require '../lib/phobos'
http = require 'http'
path = require 'path'
{parse: urlParse} = require 'url'
connect = require 'connect'
fs = require 'fs'

cwd = process.cwd()
defDir = path.join cwd, 'tests/def'

server =
  start : (opt, cb) ->
    app = connect()
    @phobos = phobos opt
    app.use @phobos.middleware()
    @handle = http.createServer(app)
    @handle.listen =>
      @port = @handle.address().port
      cb()
  stop : (cb)->
    @handle.close cb
  req : (url, data, method='get', cb) ->
    opt = port: @port, method: method.toUpperCase(), path: url
    chunks = []
    headers = {}
    status = 0
    request = http.request opt, (resp) ->
      headers = resp.headers
      status = resp.statusCode
      resp.on 'data', (chunk) -> chunks.push chunk
      resp.on 'end', -> cb Buffer.concat(chunks).toString(), headers, status
    request.write data if data
    request.end()

describe 'phobos', ->
  before ->
    process.chdir defDir
    cleans = ['./phobos_define/syntax_error.json']
    fs.unlinkSync clean for clean in cleans when fs.existsSync clean
  after -> process.chdir cwd
  describe 'init', ->
    it 'no rcfile', ->
      process.chdir cwd
      p = phobos()
      e(phobos.rewrite).to.be.empty
      process.chdir defDir
    it 'with rcfile', ->
      p = phobos()
      e(p.options.dir).to.be.eql 'phobos_define'
    it 'with error rcfile', ->
      process.chdir path.join defDir, 'error_rc'
      p = phobos()
      e(phobos.rewrite).to.be.empty
      process.chdir defDir

  describe 'parse define files', ->
    it 'ok', ->
      p = phobos()
      e(p.api).to.have.property 'person@all'
      e(p.api).to.have.property 'pp@get'
    it 'skip syntax error', ->
      fs.writeFileSync './phobos_define/syntax_error.json', fs.readFileSync './syntax_error.json'
      p = phobos()
      e(p.api).to.not.have.property 'syntax_error@all'
      fs.unlinkSync './phobos_define/syntax_error.json'
  describe 'routerApi', ->
    it 'method match', ->
      p = phobos()
      data = p.routerApi '/pp', 'get'
      e(data).to.be.a 'object'
    it 'all method', ->
      p = phobos()
      data1 = p.routerApi '/person', 'get'
      data2 = p.routerApi '/person', 'post'
      e(data1).to.be.a 'object'
      e(data1).to.be.eql data2
    it 'not match', ->
      p = phobos()
      data = p.routerApi '/not_exists', 'get'
      e(data).to.be.a 'undefined'
  describe 'middleware', ->
    before (done)->
      server.start {}, done
    after (done) -> server.stop done
    describe 'without rewrite', ->
      it 'data found', (done)->
        server.req '/pp', null, 'get', (data, headers) ->
          e(headers['content-type']).to.be.eql 'application/json; charset=utf-8'
          d = JSON.parse data
          e(d).to.have.property 'name'
          e(d).to.have.property 'content'
          done()
      it 'data not found', (done)->
        server.req '/ppppp', null, 'get', (data, headers, status) ->
          e(status).to.be.eql 404
          done()
    describe 'with rewrite', ->
      it 'wildcard to regexp', (done)->
        rewrite = server.phobos.rewrite
        e(rewrite[0].test).to.be.a 'RegExp'
        e(rewrite[0].test.toString()).to.be.eql '/^\\/aaa(.*)$/'
        done()
      it 'wildcard request', (done) ->
        server.req '/aaa', null, 'get', (data, headers) ->
          d = JSON.parse data
          e(d).to.have.property 'name'
          e(d).to.have.property 'content'
          done()
      it 'proxy', (done) ->
        server.phobos.rewrite.push test : /^\/ccc$/, target : "http://localhost:#{server.port}/pp"
        server.req '/ccc', null, 'get', (data, headers) ->
          d = JSON.parse data
          e(d).to.have.property 'name'
          e(d).to.have.property 'content'
          done()



