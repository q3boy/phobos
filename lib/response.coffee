faker = require 'mars-deimos'
lodash = require 'lodash'

class Response
  constructor : (@fakeVars, @fakerOptions) -> @fakers = {}
  trans : (data, url) -> @walk lodash.cloneDeep(data), [url]
  getFaker : (url) ->
    unless @fakers[url]
      @fakers[url] = faker url, @opt
    @fakers[url]

  walk : (obj, url, fake) ->
    switch typeof obj
      when 'string'
        obj = @getFaker(url.slice(0, url.length - 1).join '->').fake obj, @fakeVars
      when 'object'
        if Array.isArray obj
          obj[i] = @walk v, url.concat i for v, i in obj
        else
          obj[k] = @walk v, url.concat k for k, v of obj
    obj

module.exports = (data, url, fakerOptions) -> new Response data, url, fakerOptions
