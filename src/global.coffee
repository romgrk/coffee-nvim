# !::coffee [../lib]

Reflect = require 'harmony-reflect'
sync = '../dev/sync'
fiber   = sync.fiber
await   = sync.await
defer   = sync.defer

Nvim = null

module.exports = (nvim) ->
    Nvim = nvim
    for k, v of properties
        Object.defineProperty lib, k, v
    return lib

properties =
    windows:
        get: -> Nvim.getWindows()
    buffers:
        get: -> Nvim.getBuffers()
    buffer:
        get: -> Nvim.getCurrentBuffer()
        set: (b) -> Nvim.setCurrentBuffer b
    window:
        get: -> Nvim.getCurrentWindow()
        set: (b) -> Nvim.setCurrentWindow b
    tabpage:
        get: -> Nvim.getCurrentTabpage()
        set: (b) -> Nvim.setCurrentTabpage b

lib = {}

lib.echo = (args...) ->
    Nvim.command( "echo '#{args.join(' ')}'")

lib.echohl = (args...) ->
    hl = if args.length == 1 then 'TextInfo' else args[0]
    msg = if args.length == 1 then args[0] else args[1..].join ' '
    Nvim.command( "EchoHL #{hl} #{msg}")

lib.eval = (text) ->
    return Nvim.eval(text)

lib.bufnr = (expr) ->
    return Nvim.eval "bufnr('#{expr}')"

lib.bufname = (nr) ->
    return Nvim.eval("bufname(#{nr})").toString()

lib.set = (option, value) ->
    return unless option?
    if option[-1..] == '?'
        return await Nvim.getOption option[..-2], defer()
    if value?
        Nvim.setOption option, value

lib.normal = (seq, nore=true) ->
    Nvim.command "normal#{nore?'!':''} #{seq}"

lib.execute = (seq) ->
    Nvim.command seq

lib.insert = (lnum, lines) ->
    buf = Nvim.getCurrentBuffer()
    buf.insert lnum, lines

