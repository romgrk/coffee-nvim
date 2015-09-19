# !::coffee [../lib/]

Net    = require 'net'
Path   = require 'path'
Fs     = require 'fs'
util   = require 'util'
attach = require 'neovim-client'
sync   = require 'synchronize'
fiber  = sync.fiber
await  = sync.await
defer  = sync.defer

log = require 'romgrk-logger'

PORT  = 5000
LOG   = (content) -> Fs.appendFileSync 'log.txt', util.inspect(content)

Nvim = null
sock = null
stdio = [process.stdout, process.stdin]

try
    sock = Net.createConnection PORT
    console.log = (args...) -> sock.write args.join(' ')+'\n'
catch err
    LOG err
    console.log = -> # nop

echo = (args...) ->
    return unless Nvim?
    hl = if args.length == 1 then 'TextInfo' else args[0]
    msg = if args.length == 1 then args[0] else args[1..].join ' '
    Nvim.command( "EchoHL #{hl} '#{msg}'")


log.info "[#{__filename}] " + process.pid

main = (nvim) ->
    log.success 'Started... [channel='+nvim._channel_id+']'
    fiber ->
        echo "'RPC: #{Path.basename(__filename)} #{process.pid}'"
        context = require './nvim'
        #require './exec'


attach stdio[0], stdio[1], (err, nvim) ->
    if err
        log.error 'error: ' + err
        process.exit(0)

    global.Nvim = nvim
    log.debug "[#{__filename}] connected on channel " + nvim._channel_id
    echo "[#{__filename}] connected on channel " + nvim._channel_id

    sock.on 'data', (d) -> echo(d)

    nvim.on 'request', (method, args, resp) ->
        msg = method + ' ' + args
        log.warning 'request: ' + msg
        resp.send(msg)

    nvim.on 'notification', (method, args) ->
        msg = method + ' ' + args
        log.info 'notification: ' + msg

    main(nvim)

#nvim.command( "echohl textsuccess '#{__filename} running'")
#global.nvim = nvim


#main = (nvim) ->
    #log.info "RPC: #{Path.basename(__filename)} #{process.pid}"
    #fiber ->
        #nvim.command 'normal ggVG'
        #wd = new WatchDog(3500)
# end

