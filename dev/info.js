(function() {
  var ADDRESS, Clc, Net, Path, attach, await, call, defer, fiber, log, main, sock, sync, traverse;

  Path = require('path');

  Net = require('net');

  Clc = require('cli-color');

  attach = require('neovim-client');

  traverse = require('traverse');

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
    fiber(function() {
      nvim.command("EchoHL TextInfo " + ("'RPC: " + (Path.basename(__filename)) + " " + process.pid + "'"));
      require('../lib/nvim');
      return require('./exec');
    });
    return process.exit(0);
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
