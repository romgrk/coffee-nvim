# !::coffee [..]

Net    = require 'net'
Logger = require 'romgrk-logger'
attach = require 'neovim-client'

sock = null
log = null
requests = []

attach process.stdout, process.stdin, (err, nvim) ->
    if err
        process.exit 1

    nvim.on 'request', (args...) -> requests.push args

    sock = Net.createConnection 5000
    log  = Logger()
    log.method = (args...) -> sock.write args.join(' ')+'\n'
    log.success 'Connected'

    requestHandler = (method, args, resp) ->
        log.info 'req', method, args
        resp.send 0

    nvim.on 'request', requestHandler
    for req in requests
        requestHandler(req...)

