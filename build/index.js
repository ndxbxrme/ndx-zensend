(function() {
  'use strict';
  var zensend;

  zensend = require('zensend');

  module.exports = function(ndx) {
    var callbacks, client, safeCallback;
    client = new zensend.Client(process.env.ZENSEND_KEY || ndx.settings.ZENSEND_KEY);
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
    return ndx.zensend = {
      send: function(args, cb) {
        return client.sendSms(args, function(err, response) {
          if (err) {
            safeCallback('error', err);
          } else {
            safeCallback('send', response);
          }
          return typeof cb === "function" ? cb() : void 0;
        });
      }
    };
  };

}).call(this);

//# sourceMappingURL=index.js.map
