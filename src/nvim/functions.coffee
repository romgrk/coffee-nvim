# !::coffee [../../lib/nvim]

module.exports = lib = {}

lib.echo = (args...) ->
    Nvim.command( "echo '#{args.join(' ').replace(/[\\']/g, '$&')}'")

lib.echon = (args...) ->
    Nvim.command( "echon '#{args.join(' ').replace(/[\\']/g, '$&')}'")

lib.echohl = (args...) ->
    return if args.length == 0
    hl = args[0]
    if args.length == 1
        Nvim.command( "echohl #{hl}")
    else
        msg = args[1..].join ' '
        Nvim.command( "echohl #{hl}")
        Nvim.command( "echo '#{msg}'")
        Nvim.command( "echohl None")

lib.echonhl = (args...) ->
    return if args.length == 0
    hl = args[0]
    if args.length == 1
        Nvim.command( "echohl #{hl}")
    else
        msg = args[1..].join ' '
        Nvim.command( "echohl #{hl}")
        Nvim.command( "echon '#{msg}'")
        Nvim.command( "echohl None")

            .lib.eval = (text) ->
    return Nvim.eval(text)

lib.get = (varname) -> 
    return Nvim.getVar varname

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

lib.input = (keys) ->
    Nvim.input(keys)

lib.feedkeys = (args...) ->
    Nvim.feedkeys args[0], (args[1] ? 'n'), (args[2] ? false)




