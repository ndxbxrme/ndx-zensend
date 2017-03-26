'use strict'

zensend = require 'zensend'

module.exports = (ndx) ->
  client = new zensend.Client(process.env.ZENSEND_KEY or ndx.settings.ZENSEND_KEY)
  callbacks = 
    send: []
    error: []
  safeCallback = (name, obj) ->
    for cb in callbacks[name]
      cb obj
  cleanNo = (num) ->
    num = num.replace /\+|\s/g, ''
    num = num.replace /^07/, '447'
    if /^447/.test(num) then num else null
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
      args.numbers = cleanNos args.numbers
      args.body = fillTemplate args.body, data
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
        console.log 'sending sms'
        console.log args.body
        console.log args.numbers