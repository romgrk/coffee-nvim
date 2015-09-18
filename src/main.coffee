# !::coffee [.]

Net    = require 'net'
Path   = require 'path'
attach = require 'neovim-client'
sync   = require 'synchronize'
fiber  = sync.fiber
await  = sync.await
defer  = sync.defer

stdio = [process.stdout, process.stdin]
log = (msg) ->
    return unless Nvim?
    Nvim.command( "EchoHL TextInfo '#{msg}'")


main = (nvim) ->
    log "RPC: #{Path.basename(__filename)} #{process.pid}"

    fiber ->
        wd = new WatchDog(3500)
# end

class WatchDog
    constructor: (@timeout) ->
        log 'new WatchDog, timeout='+@timeout
        setInterval @check.bind(@), @timeout

    check: =>
        val = await Nvim.eval 'g:COFFEE_STOP', defer()
        if val == 1
            process.exit(0)
        else
            r = Math.floor Math.random()*6
            log(Math.random() + '\t' for i in [0..r])

attach stdio[0], stdio[1], (err, nvim) ->
    nvim.on 'request', (method, args, resp) ->
        msg = method + ' ' + args
        nvim.command "EchoHL TextError \'Request: #{msg}\'"
    nvim.on 'notification', (method, args) ->
        msg = method + ' ' + args
        nvim.command "EchoHL TextWarning \'Notification: #{msg}\'"
    global.Nvim = nvim
    main(nvim)
