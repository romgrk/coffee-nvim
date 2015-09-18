# ::coffee [.]

# Imports =================================================================={{{

Path     = require 'path'
Net      = require 'net'
attach   = require 'neovim-client'
sync     = require 'synchronize'
fiber    = sync.fiber
await    = sync.await
defer    = sync.defer
call     = (fun) -> await fun defer()

log = require 'romgrk-logger'

#===========================================================================}}}
# Definitions =============================================================={{{

ADDRESS=process.env.NVIM_LISTEN_ADDRESS

#===========================================================================}}}

log.success("Connecting on #{ADDRESS}")
sock = Net.createConnection {port: 6666}, '127.0.0.1'

main = (nvim) ->
    log.success 'Started... [channel='+nvim._channel_id+']'
    fiber ->

        nvim.command( "EchoHL TextInfo " +
            "'RPC: #{Path.basename(__filename)} #{process.pid}'")

        require '../lib/nvim'
        require './exec'

    process.exit(0)

attach sock, sock, (err, nvim) ->
    nvim.on 'request', (method, args, resp) ->
        log.warning 'Request : ', method, args
    nvim.on 'notification', (method, args) ->
        log.info 'Notification : ', method, args
    nvim.on 'disconnect', (method, args) ->
        log.error 'Session disconnected.'
        process.exit(0)
    global.Nvim = nvim
    main(nvim)

