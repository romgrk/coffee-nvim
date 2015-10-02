// Generated by CoffeeScript 1.10.0
(function() {
  var BufferProxy, CursorProxy, DEFINE, Path, Reflect, SYNCHRONIZE, TabpageProxy, VimProxy, WindowProxy, _, await, base, defer, fiber, lib, superClass, sync,
    slice = [].slice;

  _ = require('lodash');

  Path = require('path');

  Reflect = require('harmony-reflect');

  sync = require('synchronize');

  fiber = sync.fiber;

  await = sync.await;

  defer = sync.defer;

  module.exports = lib = {};

  superClass = function(type) {
    return type.__super__ = _.extend({}, type.prototype);
  };

  DEFINE = function(properties) {
    return Object.defineProperties(lib, properties);
  };

  SYNCHRONIZE = function(object) {
    var apiFunc, func, k, ref, results, v;
    results = [];
    for (k in object) {
      v = object[k];
      apiFunc = ((ref = object[k]) != null ? ref.metadata : void 0) != null;
      if (!apiFunc) {
        continue;
      }
      func = object[k];
      sync(object, k);
      results.push(object[k].metadata = func.metadata);
    }
    return results;
  };

  global.RESULT = function(object) {
    if (Buffer.isBuffer(object)) {
      return object.toString();
    }
    return object;
  };

  SYNCHRONIZE(Nvim);

  SYNCHRONIZE(Nvim.Buffer.prototype);

  SYNCHRONIZE(Nvim.Window.prototype);

  SYNCHRONIZE(Nvim.Tabpage.prototype);

  VimProxy = require('./nvim/vim');

  CursorProxy = require('./nvim/cursor');

  BufferProxy = require('./nvim/buffer');

  TabpageProxy = require('./nvim/tabpage');

  WindowProxy = require('./nvim/window');

  superClass(Nvim.Buffer);

  Nvim.Buffer.prototype.getProxy = function() {
    return this._proxy != null ? this._proxy : this._proxy = new BufferProxy(this);
  };

  superClass(Nvim.Tabpage);

  Nvim.Tabpage.prototype.getProxy = function() {
    return this._proxy != null ? this._proxy : this._proxy = new TabpageProxy(this);
  };

  superClass(Nvim.Window);

  Nvim.Window.prototype.getProxy = function() {
    return this._proxy != null ? this._proxy : this._proxy = new WindowProxy(this);
  };

  (base = Nvim.Window).prototype.getCursor = function() {
    return new CursorProxy(this, base.__super__.getCursor.call(this));
  };

  lib.Nvim = Nvim;

  lib.nvim = Nvim;

  DEFINE({
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
        return _.map(Nvim.getBuffers(), function(b) {
          return b.getProxy();
        });
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
        return _.map(Nvim.getWindows(), function(b) {
          return b.getProxy();
        });
      }
    },
    tabpage: {
      get: function() {
        return Nvim.getCurrentTabpage().getProxy();
      },
      set: function(b) {
        return Nvim.setCurrentTabpage(b);
      }
    },
    tabpages: {
      get: function() {
        return _.map(Nvim.getTabpages(), function(b) {
          return b.getProxy();
        });
      }
    }
  });

  DEFINE({
    cursor: {
      get: function() {
        return Nvim.getCurrentWindow().getCursor();
      },
      set: function(val) {
        var ref, ref1;
        if (typeof val === 'number') {
          return Nvim.getCurrentWindow().setCursor([val, 0]);
        } else if (typeof val === 'object') {
          return Nvim.getCurrentWindow().setCursor([(ref = val.line) != null ? ref : cursor.line, (ref1 = val.row) != null ? ref1 : cursor.row]);
        } else {
          return Nvim.getCurrentWindow().setCursor([val[0], val[1]]);
        }
      }
    }
  });

  DEFINE({
    vim: {
      value: new VimProxy()
    }
  });

  DEFINE({
    call: {
      value: new Proxy({}, {
        get: function(t, fn) {
          return function() {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return Nvim.callFunction(fn, args != null ? args : []);
          };
        }
      })
    }
  });

  _.extend(lib, require('./nvim/functions'));

}).call(this);