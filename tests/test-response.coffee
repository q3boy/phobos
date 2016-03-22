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
  somekey : '#{somekey}'
  address : '#{address}'

describe 'Response', ->
  describe 'random seed', ->
    it 'base on url', ->
      r = response somekey : 'somevalue'
      r1 = r.trans(tpl, '/abc')
      r2 = r.trans(tpl, '/def')
      e(r1).to.have.property 'name'
      e(r2).to.have.property 'name'
      e(r1).to.be.not.eql r2
    it 'change when indent', ->
      r = response(somekey : 'somevalue').trans(tpl, '/abc')
      e(r).to.have.property 'name'
      e(r.name).to.be.eql r.name1
      e(r.name).to.be.not.eql r.child.name1
      e(r.name).to.be.not.eql r.list[0].name
      e(r.child.name1).to.be.eql r.child.name2
      e(r.list[0].name).to.be.not.eql r.list[1].name
      e(r.name).to.be.eql r.name2
  describe 'with user-defined vars', ->
    it 'not overwrite demios predefined', ->
      r = response somekey : 'somevalue'
      r = r.trans(tpl, '/abc')
      e(r.somekey).to.be.eql 'somevalue'
    it 'overwrite demios predefined', ->
      r = response somekey : 'somevalue', address: 'address'
      r = r.trans(tpl, '/abc')
      e(r.address).to.be.eql 'address'
  describe 'with url querystring', ->
    it 'ok', ->
      r = response somekey : 'somevalue'
      r = r.trans(Object.assign({}, tpl, {getkey: '#{GET.somekey}', postkey: '#{POST.somekey}'}), '/abc?somekey=somevalue', somekey : 'somevalue')
      e(r.getkey).to.be.eql 'somevalue'
      e(r.postkey).to.be.eql 'somevalue'



