{expect: e} = require 'chai'
response = require '../lib/response'
tpl =
  name : '#{person.name}'
  name1 : '#{person.name}'
  child : {
    name1 : '#{person.name}'
    name2 : '#{person.name}'
  }
  list : [
    {name : '#{person.name}'}
    {name : '#{person.name}'}
  ]
  name2 : '#{person.name}'

describe 'Response', ->
  it 'url as key', ->
    r = response()
    r1 = r.trans(tpl, '/abc')
    r2 = r.trans(tpl, '/def')
    e(r1).to.have.property 'name'
    e(r2).to.have.property 'name'
    e(r1).to.be.not.eql r2
  it 'child key', ->
    r = response().trans(tpl, '/abc')
    e(r).to.have.property 'name'
    e(r.name).to.be.eql r.name1
    e(r.name).to.be.not.eql r.child.name1
    e(r.name).to.be.not.eql r.list[0].name
    e(r.child.name1).to.be.eql r.child.name2
    e(r.list[0].name).to.be.not.eql r.list[1].name
    e(r.name).to.be.eql r.name2
