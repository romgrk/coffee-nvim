// Generated by CoffeeScript 1.10.0
(function() {
  var Reflect, VimProxy;

  Reflect = require('harmony-reflect');

  module.exports = VimProxy = (function() {
    function VimProxy() {
      return new Proxy({}, this);
    }

    VimProxy.prototype.get = function(target, name, receiver) {
      var error, error1;
      if (name in target) {
        return target[name];
      }
      try {
        return Nvim.getVvar(name);
      } catch (error1) {
        error = error1;
        return void 0;
      }
    };

    VimProxy.prototype.set = function(target, name, val, receiver) {
      return false;
    };

    return VimProxy;

  })();

}).call(this);