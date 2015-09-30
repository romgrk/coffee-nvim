# !::coffee [../lib]

# Imports =================================================================={{{

_       = require 'lodash'
Path    = require 'path'
Reflect = require 'harmony-reflect'
sync    = require 'synchronize'
fiber   = sync.fiber
await   = sync.await
defer   = sync.defer

#===========================================================================}}}

# Define class
superClass = (type) ->
    type.__super__ = _.extend({}, type::)

# Define properties
define = (obj, properties) -> 
    Object.defineProperties obj, properties

# Synchronize API functions, whilst keeping metadata
synchronize = (object) ->
    for k, v of object
        apiFunc = object[k]?.metadata?
        continue unless apiFunc
        func = object[k]
        sync(object, k)
        object[k].metadata = func.metadata

#===========================================================================}}}


synchronize Nvim
synchronize Nvim.Buffer::
synchronize Nvim.Window::
synchronize Nvim.Tabpage::

VimProxy     = require('./nvim/vim')
CursorProxy  = require('./nvim/cursor')
BufferProxy  = require('./nvim/buffer')
TabpageProxy = require('./nvim/tabpage')
WindowProxy  = require('./nvim/window')

superClass(Nvim.Buffer)
Nvim.Buffer::getProxy = -> @_proxy ?= new BufferProxy(@)

superClass(Nvim.Tabpage)
Nvim.Tabpage::getProxy = -> @_proxy ?= new TabpageProxy @

superClass(Nvim.Window)
Nvim.Window::getProxy = -> @_proxy ?= new WindowProxy @
Nvim.Window::getCursor = -> new CursorProxy @, super()

# Lib setup
module.exports = lib = {}

lib.Nvim = Nvim
lib.nvim = Nvim

define lib, 
    buffer:
        get: -> Nvim.getCurrentBuffer().getProxy()
        set: (b) -> Nvim.setCurrentBuffer b
    buffers:
        get: -> _.map Nvim.getBuffers(), (b) -> b.getProxy()
    window:
        get: -> Nvim.getCurrentWindow().getProxy()
        set: (b) -> Nvim.setCurrentWindow b
    windows:
        get: -> _.map Nvim.getWindows(), (b) -> b.getProxy()
    tabpage:
        get: -> Nvim.getCurrentTabpage().getProxy()
        set: (b) -> Nvim.setCurrentTabpage b
    tabpages:
        get: -> _.map Nvim.getTabpages(), (b) -> b.getProxy()

define lib, cursor:
    get: -> 
        Nvim.getCurrentWindow().getCursor()
    set: (val) ->
        if typeof val is 'number'
            Nvim.getCurrentWindow().setCursor [val, 0]
        else
            Nvim.getCurrentWindow().setCursor [val[0], val[1]]
            
define lib, vim:
    value: new VimProxy()

# Functions
_.extend lib, require('./nvim/functions')




