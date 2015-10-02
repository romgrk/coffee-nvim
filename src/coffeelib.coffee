# !::coffee [../lib]

# Imports =================================================================={{{

_       = require 'lodash'
Path    = require 'path'
Reflect = require 'harmony-reflect'
sync    = require 'synchronize'
fiber   = sync.fiber
await   = sync.await
defer   = sync.defer

hh = require './helpers'

#===========================================================================}}}
# lib global context

module.exports = lib = {}

#===========================================================================}}}
# Helpers

# Define properties
DEFINE = (properties) -> 
    Object.defineProperties lib, properties

# Synchronize API functions, whilst keeping metadata
SYNCHRONIZE = (object) ->
    for k, v of object
        apiFunc = object[k]?.metadata?
        continue unless apiFunc
        func = object[k]
        sync(object, k)
        object[k].metadata = func.metadata

#===========================================================================}}}

# Make API functions sync unless called with callback
SYNCHRONIZE Nvim
SYNCHRONIZE Nvim.Buffer::
SYNCHRONIZE Nvim.Window::
SYNCHRONIZE Nvim.Tabpage::

# Proxy objects
VimProxy     = require('./nvim/vim')
CursorProxy  = require('./nvim/cursor')
BufferProxy  = require('./nvim/buffer')
TabpageProxy = require('./nvim/tabpage')
WindowProxy  = require('./nvim/window')

hh.superClass(Nvim)

# Lib setup
lib.Nvim = Nvim
lib.nvim = Nvim

# current objects
DEFINE 
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

# current cursor
DEFINE cursor:
    get: -> 
        Nvim.getCurrentWindow().getCursor()
    set: (val) ->
        if typeof val is 'number'
            Nvim.getCurrentWindow().setCursor [val, 0]
        else if typeof val is 'object'
            Nvim.getCurrentWindow().setCursor [val.line ? cursor.line, val.row ? cursor.row]
        else
            Nvim.getCurrentWindow().setCursor [val[0], val[1]]

# Vim vars
DEFINE vim:
    value: new VimProxy()

# call.FUNCNAME -> Nvim.callFunction "FUNCNAME", args...
DEFINE call:
    value: new Proxy {}, get: (t, fn) -> 
        (args...) -> Nvim.callFunction(fn, args ? [])

# Functions
_.extend lib, require('./nvim/functions')




