# !::coffee [.]

Net    = require 'net'
Path   = require 'path'
Clc    = require 'cli-color'
attach = require 'neovim-client'
sync   = require 'synchronize'
fiber  = sync.fiber
await  = sync.await
defer  = sync.defer

main = (nvim) ->
    nvim.command( "EchoHL TextInfo " +
        "'RPC: #{Path.basename(__filename)} #{process.pid}'"
    )
    # NOP

attach process.stdout, process.stdin, (err, nvim) ->
    nvim.on 'request', (method, args, resp) ->
        msg = method + ' ' + args
        nvim.command "EchoHL TextError \'Request: #{msg}\'"
    nvim.on 'notification', (method, args) ->
        msg = method + ' ' + args
        nvim.command "EchoHL TextWarning \'Notification: #{msg}\'"

    main(nvim)
