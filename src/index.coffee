'use strict'

zensend = require 'zensend'

module.exports = (ndx) ->
  client = new zensend.Client process.env.ZENSEND_KEY or ndx.settings.ZENSEND_KEY
  callbacks = 
    send: []
    error: []
  safeCallback = (name, obj) ->
    for cb in callbacks[name]
      cb obj
  ndx.zensend =
    send: (args, cb) ->
      client.sendSms args, (err, response) ->
        if err
          safeCallback 'error', err
        else
          safeCallback 'send', response
        cb?()