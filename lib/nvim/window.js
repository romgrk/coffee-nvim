// Generated by CoffeeScript 1.10.0
(function() {
  var Functions, Reflect, Window, WindowProxy, base, base1, base2, hh;

  hh = require('../helpers');

  Functions = require('./functions');

  Reflect = require('harmony-reflect');

  hh.superClass(Nvim.Window);

  Nvim.Window.prototype.getProxy = function() {
    return this._proxy != null ? this._proxy : this._proxy = new WindowProxy(this);
  };

  (base = Nvim.Window).prototype.getCursor = function() {
    return new CursorProxy(this, base.__super__.getCursor.call(this));
  };

  (base1 = Nvim.Window).prototype.getBuffer = function() {
    return base1.__super__.getBuffer.call(this).getProxy();
  };

  (base2 = Nvim.Window).prototype.getTabpage = function() {
    return base2.__super__.getTabpage.call(this).getProxy();
  };

  Nvim.Window.prototype["do"] = function(cmd) {
    var winnr;
    winnr = this.number;
    if ((winnr == null) || typeof winnr !== 'number') {
      log.warn('windo: abort: ', winnr);
      return;
    }
    return Nvim.command(winnr + 'windo ' + cmd);
  };

  Nvim.Window.prototype.close = function() {
    return this["do"]('close');
  };

  Window = (function() {
    function Window(num) {
      var ref;
      if ((num != null) && typeof num === 'number') {
        return (ref = Nvim.getWindows()[num - 1]) != null ? ref : null;
      }
      Nvim.command('new | let g:Window_new = winnr()');
      num = eval('g:Window_new');
      return Nvim.getWindows()[num - 1];
    }

    return Window;

  })();

  Window.properties = {
    number: {
      get: function() {
        var i, j, len, ref, w;
        ref = Nvim.getWindows();
        for (i = j = 0, len = ref.length; j < len; i = ++j) {
          w = ref[i];
          if (w.equals(this)) {
            return i + 1;
          }
        }
      }
    },
    buffer: {
      get: function() {
        return this.getBuffer();
      }
    },
    width: {
      get: function() {
        return this.getWidth();
      },
      set: function(v) {
        return this.setWidth(v);
      }
    },
    height: {
      get: function() {
        return this.getHeight();
      },
      set: function(v) {
        return this.setHeight(v);
      }
    },
    cursor: {
      get: function() {
        return this.getCursor();
      },
      set: function(v) {
        return this.setCursor(v);
      }
    },
    position: {
      get: function() {
        return this.getPosition();
      }
    },
    tabpage: {
      get: function() {
        return this.getTabpage();
      }
    },
    valid: {
      get: function() {
        return this.isValid();
      }
    },
    status: hh.getOptionDesc('statusline')
  };

  WindowProxy = (function() {
    function WindowProxy(target) {
      Object.defineProperties(target, Window.properties);
      return new Proxy(target, this);
    }

    WindowProxy.prototype.get = function(target, name, receiver) {
      var optName, varName;
      switch (name.charAt(0)) {
        case ':':
          varName = name.substring(1);
          return target.getVar(varName);
        case '&':
          optName = name.substring(1);
          return target.getOption(optName);
      }
      if (name in target) {
        return target[name];
      }
      return void 0;
    };

    WindowProxy.prototype.set = function(target, name, val, receiver) {
      var optName, varName;
      if (name.charAt(0) === ':') {
        varName = name.substring(1);
        target.setVar(varName, val);
      } else if (name.charAt(0) === '&') {
        optName = name.substring(1);
        target.setOption(optName, val);
      } else {
        target[name] = val;
      }
      return true;
    };

    return WindowProxy;

  })();

  module.exports = {
    WindowProxy: WindowProxy,
    Window: Window
  };

}).call(this);
