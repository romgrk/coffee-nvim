# !::coffee [../lib]

# Imports =================================================================={{{

Path     = require 'path'
sync     = require '../dev/sync'
fiber    = sync.fiber
await    = sync.await
defer    = sync.defer

#===========================================================================}}}

module.exports = context = {}

properties =
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

context.init = ->
    for key, definition of properties
        Object.defineProperty context, key, definition
    BufferPrototype = Object.getPrototypeOf(context.buffer)
    for k, def of context.Buffer
        Object.defineProperty BufferPrototype, k, def
    sync BufferPrototype, 'getVar', 'setVar'

context.echo = (args...) ->
    Nvim.command( "echo '#{args.join('')}'")

context.echohl = (args...) ->
    hl = if args.length == 1 then 'TextInfo' else args[0]
    msg = if args.length == 1 then args[0] else args[1..].join ' '
    Nvim.command( "EchoHL #{hl} #{msg}")

context.eval = (text) ->
    return await Nvim.eval text, defer()

context.bufnr = (expr) ->
    return await Nvim.eval "bufnr('#{expr}')", defer()

context.bufname = (nr) ->
    return await(Nvim.eval "bufname(#{nr})", defer()).toString()

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

context.Buffer =
    length:
        get: -> return await @lineCount defer()
    number:
        get: -> return await @getNumber defer()
    name:
        get: -> return await @getName defer()
        set: (v) -> @setName(v)


