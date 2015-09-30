// Generated by CoffeeScript 1.10.0
(function() {
  var Reflect;

  Reflect = require('harmony-reflect');

  module.exports = {
    buffer: {
      get: function() {
        return Nvim.getCurrentBuffer().getProxy();
      },
      set: function(b) {
        return Nvim.setCurrentBuffer(b);
      }
    },
    buffers: {
      get: function() {
        return Nvim.getBuffers();
      }
    },
    window: {
      get: function() {
        return Nvim.getCurrentWindow().getProxy();
      },
      set: function(b) {
        return Nvim.setCurrentWindow(b);
      }
    },
    windows: {
      get: function() {
        return Nvim.getWindows();
      }
    },
    tabpage: {
      get: function() {
        return Nvim.getCurrentTabpage().getProxy();
      },
      set: function(b) {
        return Nvim.setCurrentTabpage(b);
      }
    }
  };

}).call(this);