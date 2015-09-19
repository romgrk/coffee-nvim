(function() {
  var ADDRESS, Net, Path, attach, await, call, defer, fiber, log, main, sock, sync;

  Path = require('path');

  Net = require('net');

  attach = require('neovim-client');

  sync = require('synchronize');

  fiber = sync.fiber;

  await = sync.await;

  defer = sync.defer;

  call = function(fun) {
    return await(fun(defer()));
  };

  log = require('romgrk-logger');

  ADDRESS = process.env.NVIM_LISTEN_ADDRESS;

  log.success("Connecting on " + ADDRESS);

  sock = Net.createConnection({
    port: 6666
  }, '127.0.0.1');

  main = function(nvim) {
    log.success('Started... [channel=' + nvim._channel_id + ']');
    return fiber(function() {
      nvim.command("EchoHL TextInfo " + ("'RPC: " + (Path.basename(__filename)) + " " + process.pid + "'"));
      require('../lib/nvim');
      return require('./exec');
    });
  };

  attach(sock, sock, function(err, nvim) {
    nvim.on('request', function(method, args, resp) {
      return log.warning('Request : ', method, args);
    });
    nvim.on('notification', function(method, args) {
      return log.info('Notification : ', method, args);
    });
    nvim.on('disconnect', function(method, args) {
      log.error('Session disconnected.');
      return process.exit(0);
    });
    global.Nvim = nvim;
    return main(nvim);
  });

}).call(this);
