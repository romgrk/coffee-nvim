// Generated by CoffeeScript 1.10.0
(function() {
  var b, i, len, log;

  log = require('romgrk-logger');

  log.warning(set('cpo?'));

  log.success(eval('@@'));

  log.warning(eval('g:LASTSESSION'));

  execute('2wincmd w');

  log.warning('buffer: ', buffer, typeof buffer);

  defineObjects();

  for (i = 0, len = buffers.length; i < len; i++) {
    b = buffers[i];
    log.success(b.number + ': ' + b.name);
  }

}).call(this);
