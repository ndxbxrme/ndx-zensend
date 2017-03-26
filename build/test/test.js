(function() {
  'use strict';
  var ndx;

  ndx = {};

  require('../index')(ndx);

  ndx.zensend.send({
    originator: 'test',
    body: 'This is a test',
    numbers: ['']
  }, function(err, res) {
    console.log('error', err);
    return console.log('res', res);
  });

}).call(this);

//# sourceMappingURL=test.js.map
