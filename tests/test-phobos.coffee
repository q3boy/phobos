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
    # @phobos = new phobos.Phobos opt
    app.use mw = phobos(opt)
    @phobos = mw.phobos
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
      p = new phobos.Phobos()
      e(phobos.rewrite).to.be.empty
      process.chdir defDir
    it 'with rcfile', ->
      p = new phobos.Phobos()
      e(p.options.dir).to.be.eql 'phobos_define'
    it 'with error rcfile', ->
      process.chdir path.join defDir, 'error_rc'
      p = new phobos.Phobos()
      e(phobos.rewrite).to.be.empty
      process.chdir defDir
  describe 'routerApi', ->
    it 'method match', ->
      p = new phobos.Phobos()
      data = p.routerApi '/pp', 'get'
      e(data).to.be.a 'object'
    it 'all method', ->
      p = new phobos.Phobos()
      data1 = p.routerApi '/person', 'get'
      data2 = p.routerApi '/person', 'post'
      e(data1).to.be.a 'object'
      e(data1).to.be.eql data2
    it 'file not found', ->
      p = new phobos.Phobos()
      data = p.routerApi '/not_exists', 'get'
      e(data).to.be.a 'undefined'
    it 'method not match', ->
      p = new phobos.Phobos()
      data = p.routerApi '/person', 'aaa'
      e(data).to.be.a 'undefined'
    it 'syntax_error', ->
      fs.writeFileSync './phobos_define/syntax_error.json', fs.readFileSync './syntax_error.json'
      p = new phobos.Phobos()
      data = p.routerApi '/syntax_error', 'get'
      e(data).to.be.a 'undefined'
      fs.unlinkSync './phobos_define/syntax_error.json'
  describe 'middleware', ->
    before (done)->
      server.start {}, done
    after (done) -> server.stop done
    describe 'http method', ->
      it 'is get', (done)->
        server.req '/method/mget?somekey=somevalue', null, 'get', (data, headers) ->
          e(headers['content-type']).to.be.eql 'application/json; charset=utf-8'
          d = JSON.parse data
          e(d.somekey).to.be.eql 'somevalue'
          done()
      it 'is post', (done)->
        server.req '/method/mpost', '{"somekey":"somevalue"}', 'post', (data, headers) ->
          e(headers['content-type']).to.be.eql 'application/json; charset=utf-8'
          d = JSON.parse data
          e(d.somekey).to.be.eql 'somevalue'
          done()
      it 'is mixed', (done)->
        server.req '/method/mmix?somekey=getvalue', '{"somekey":"postvalue"}', 'post', (data, headers) ->
          e(headers['content-type']).to.be.eql 'application/json; charset=utf-8'
          d = JSON.parse data
          console.log(d)
          e(d.getkey).to.be.eql 'getvalue'
          e(d.postkey).to.be.eql 'postvalue'
          done()
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



