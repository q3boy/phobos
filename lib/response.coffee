faker = require 'mars-deimos'
lodash = require 'lodash'
{parse: urlParse} = require 'url'

class Response
  constructor : (@fakeVars, @fakerOptions) -> @fakers = {}

  trans : (data, url, @post) ->
    {query:@get} = urlParse url, true
    @walk lodash.cloneDeep(data), [url]

  getFaker : (url) ->
    @fakers[url] = faker url, @opt unless @fakers[url]
    @fakers[url]

  walk : (obj, url) ->
    switch typeof obj
      when 'string'
        obj = @getFaker(url.slice(0, url.length - 1).join '->').fake obj, Object.assign({}, @fakeVars, {GET:@get, POST:@post})
      when 'object'
        if Array.isArray obj
          obj[i] = @walk v, url.concat i for v, i in obj
        else
          obj[k] = @walk v, url.concat k for k, v of obj
    obj

module.exports = (data, url, fakerOptions) -> new Response data, url, fakerOptions

