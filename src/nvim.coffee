# ::coffee [.]

# Imports =================================================================={{{

Path     = require 'path'
Net      = require 'net'
Clc      = require 'cli-color'
attach   = require 'neovim-client'
sync     = require 'synchronize'
fiber    = sync.fiber
await    = sync.await
defer    = sync.defer

# }}}
#=============================================================================

#module.exports = (a, b) ->

# Vim functions ============================================================{{{

current =
    windows:
        get: -> await Nvim.getWindows defer()
    buffers:
        get: -> await Nvim.getBuffers defer()
    buffer:
        get: -> await Nvim.getCurrentBuffer defer()
        set: (b) -> Nvim.setCurrentBuffer b
    window:
        get: -> await Nvim.getCurrentWindow defer()
        set: (b) -> Nvim.setCurrentWindow b
    tab:
        get: -> await Nvim.getCurrentTabpage defer()
        set: (b) -> Nvim.setCurrentTabpage b

#end Buffer

for key, def of current
    Object.defineProperty context, key, def
    console.log 'context.'+key, def

context.eval = (text) ->
    return await Nvim.eval text, defer()

context.set = (option, value) ->
    return unless option?
    if option[-1..] == '?'
        return await Nvim.getOption option[..-2], defer()
    if value?
        Nvim.setOption option, value

context.normal = (seq, nore=true) ->
    Nvim.command "normal#{nore?'!':''} #{seq}"

context.execute = (seq) ->
    Nvim.command seq

context.insert = (lnum, lines) ->
    buf = await Nvim.getCurrentBuffer defer()
    buf.insert lnum, lines

#===========================================================================}}}

bufprops =
    length:
        get: -> return await @lineCount defer()
    number:
        get: -> return await @getNumber defer()
    name:
        get: -> return await @getName defer()
        set: (v) -> @setName(v)

context.defineObjects = ->
    Buffer = Object.getPrototypeOf buffer
    for k, def of bufprops
        Object.defineProperty Buffer, k, def

