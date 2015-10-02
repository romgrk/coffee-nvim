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

Nvim = global.Nvim

# Make API functions sync unless called with callback
SYNCHRONIZE Nvim
SYNCHRONIZE Nvim.Buffer::
SYNCHRONIZE Nvim.Window::
SYNCHRONIZE Nvim.Tabpage::

# Definitions
Nvim         = require('./nvim/nvim')
BufferProxy  = require('./nvim/buffer')
TabpageProxy = require('./nvim/tabpage')
WindowProxy  = require('./nvim/window')
{CurrentProxy, VimProxy, CursorProxy} = require('./nvim/proxies')

# Reference
lib.Nvim = lib.nvim = Nvim

# current objects
DEFINE current:
    value: new CurrentProxy

DEFINE
    buffers:
        get: -> 
            _.filter Nvim.getBuffers(), (b) -> b.listed
    windows:
        get: -> Nvim.getWindows()
    tabs:
        get: -> Nvim.getTabpages()

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




