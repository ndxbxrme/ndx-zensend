(function() {
  'use strict';
  var zensend;

  zensend = require('zensend');

  module.exports = function(ndx) {
    var callbacks, cleanNo, cleanNos, client, fillTemplate, safeCallback;
    callbacks = {
      send: [],
      error: []
    };
    safeCallback = function(name, obj) {
      var cb, i, len, ref, results;
      ref = callbacks[name];
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        cb = ref[i];
        results.push(cb(obj));
      }
      return results;
    };
    cleanNo = function(num) {
      num = num.replace(/\+|\s/g, '');
      num = num.replace(/^07/, '447');
      if (/^447/.test(num)) {
        return num;
      } else {
        return null;
      }
    };
    cleanNos = function(nos) {
      var i, len, num, outno, outnos;
      outnos = [];
      for (i = 0, len = nos.length; i < len; i++) {
        num = nos[i];
        if (outno = cleanNo(num)) {
          outnos.push(outno);
        }
      }
      return outnos;
    };
    fillTemplate = function(template, data) {
      return template.replace(/\{\{(.+?)\}\}/g, function(all, match) {
        var evalInContext;
        evalInContext = function(str, context) {
          return (new Function("with(this) {return " + str + "}")).call(context);
        };
        return evalInContext(match, data);
      });
    };
    if (process.env.ZENSEND_KEY || ndx.settings.ZENSEND_KEY) {
      client = new zensend.Client(process.env.ZENSEND_KEY || ndx.settings.ZENSEND_KEY);
    }
    return ndx.zensend = {

      /*
      https://zensend.io/documentation
      args:
        originator: String
        body: String
        numbers: Array[String]
        * originator_type: String (alpha/msisdn)
        * time_to_live_in_minutes: Number
        * encoding: String (gsm/ucs2)
       */
      send: function(args, data, cb) {
        if (process.env.ZENSEND_KEY || ndx.settings.ZENSEND_KEY) {
          args.numbers = cleanNos(args.numbers);
          args.body = fillTemplate(args.body, data);
          if (process.env.ZENSEND_OVERRIDE) {
            args.numbers = [process.env.ZENSEND_OVERRIDE];
          }
          if (!process.env.ZENSEND_DISABLE) {
            if (args.numbers.length) {
              return client.sendSms(args, function(err, response) {
                if (err) {
                  safeCallback('error', err);
                } else {
                  safeCallback('send', response);
                }
                return typeof cb === "function" ? cb(err, response) : void 0;
              });
            }
          } else {
            return console.log('sending sms disabled');
          }
        } else {
          console.log('no zensend key');
          return typeof cb === "function" ? cb('no key') : void 0;
        }
      }
    };
  };

}).call(this);

//# sourceMappingURL=index.js.map
