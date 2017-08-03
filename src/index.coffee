'use strict'

zensend = require 'zensend'

module.exports = (ndx) ->
  callbacks = 
    send: []
    error: []
  safeCallback = (name, obj) ->
    for cb in callbacks[name]
      cb obj
  cleanNo = (num) ->
    num = num.replace /\+|\s/g, ''
    num = num.replace /^07/, '447'
    if /^447/.test(num) and /^\d+$/.test(num) then num else null
  cleanNos = (nos) ->
    outnos = []
    for num in nos
      if outno = cleanNo num
        outnos.push outno
    outnos
  fillTemplate = (template, data) ->
    template.replace /\{\{(.+?)\}\}/g, (all, match) ->
      evalInContext = (str, context) ->
        (new Function("with(this) {return #{str}}"))
        .call context
      evalInContext match, data
  if process.env.ZENSEND_KEY or ndx.settings.ZENSEND_KEY
    client = new zensend.Client(process.env.ZENSEND_KEY or ndx.settings.ZENSEND_KEY)
  ndx.zensend =
    ###
    https://zensend.io/documentation
    args:
      originator: String
      body: String
      numbers: Array[String]
      * originator_type: String (alpha/msisdn)
      * time_to_live_in_minutes: Number
      * encoding: String (gsm/ucs2)
    ###
    send: (args, data, cb) ->
      if process.env.ZENSEND_KEY or ndx.settings.ZENSEND_KEY
        try
          args.numbers = cleanNos args.numbers
          args.body = fillTemplate args.body, data
        catch e
          console.log 'there was a problem filling the sms template'
          console.log args.body
          return cb? 'template error'
        if process.env.ZENSEND_OVERRIDE
          args.numbers = [process.env.ZENSEND_OVERRIDE]
        if not process.env.ZENSEND_DISABLE
          if args.numbers.length
            client.sendSms args, (err, response) ->
              if err
                safeCallback 'error', err
              else
                safeCallback 'send', response
              cb? err, response
        else
          console.log 'sending sms disabled'
      else
        console.log 'no zensend key'
        cb? 'no key'