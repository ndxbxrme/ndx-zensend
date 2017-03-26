'use strict'

ndx = {}
require('../index')(ndx)
ndx.zensend.send
  originator: 'test'
  body: 'This is a test'
  numbers: ['']
, (err, res) ->
  console.log 'error', err
  console.log 'res', res 