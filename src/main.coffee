# !::coffee [../lib/]

# Imports =================================================================={{{

_    = require 'lodash'
Net  = require 'net'
Path = require 'path'
Fs   = require 'fs'
Vm   = require 'vm'

attach  = require 'neovim-client'
Reflect = require 'harmony-reflect'
Logger  = require 'romgrk-logger'

coffee = require '../dev/compile'
sync   = require '../dev/sync'
fiber  = sync.fiber
await  = sync.await
defer  = sync.defer

argv = require('minimist')(process.argv.slice(2))
# }}}
# Settings ================================================================={{{

log  = Logger(console.log)

argv.s ?= false

PORT = 5000
sock = Net.createConnection PORT

#===========================================================================}}}

Nvim = null
lib  = null

evalMethod = null

# List of handlers for nvim requests
handlers = {}

# Stdio for msgpack data transfer
stdio = [process.stdout, process.stdin]
if argv.s == true
    nvimSocket = Net.createConnection port:6666
    stdio = [nvimSocket, nvimSocket]

# Socket data
dataHandler = (data) ->
    evalMethod ?= evalHandler
    data = data.toString().trim()
    if data == 'vm'
        log.info 'Evaluating with vm'
        evalMethod = vmHandler
        return
    if data == 'eval'
        log.info 'Evaluating with eval'
        evalMethod = evalHandler
        return
    coffee data, (status, code) ->
        if status == 0
            fiber -> evalMethod(code)
        else
            log.error 'couldnt compile: ', data

# Vm run
vmHandler = (code) ->
    try
        context = require './nvim'
        _.extend context, global
        sandbox = Vm.createContext context
        fiber ->
            Vm.runInContext code, context
            if sandbox.res?
                log.debug sandbox.res
    catch e
        log.error e, e.stack

# Eval try/catch
evalHandler = (code) ->
    try
        result = eval(code)
        if typeof result is 'object'
            log.inspect result
        else if result?
            log.debug result
    catch e
        log.error e, e.stack

# RPC request/notification handlers
onNvimNotification = (method, args) ->
    log.info 'Notification: ', method, args.toString()
    if handlers[method]?
        fiber -> handlers[method] args...

onNvimRequest = (method, args, resp) ->
    log.info 'Request: ', method, args.toString()
    resp.send null

handlers['RunBuffer'] = (nr) ->
    try
        file = lib.bufname(nr)
        content = Fs.readFileSync file
        [status, code] = coffee(content)
        evalMethod(code ) if status == 0
        throw new Error("couldnt compile "+file) if status == 1
    catch e
        log.error e, e.stack

# Log server
sock.on 'data', dataHandler
log.method = (args...) -> sock.write args.join(' ')+'\n'

log.success "lib/main running, -s=#{argv.s}"

fiber ->
    Nvim = await attach stdio[0], stdio[1], defer()
    global.Nvim = Nvim
    if Nvim instanceof Error
        log.error 'error connecting to neovim: ' + err
        process.exit(1)
    log.success 'connected to neovim, channel=' + Nvim._channel_id
    Nvim.on 'notification', onNvimNotification
    Nvim.on 'request', onNvimRequest

    lib = require './nvim'
    #lib.init()
    evalMethod = evalHandler

    Nvim.command "com! RunBuffer call rpcnotify(#{Nvim._channel_id}, 'RunBuffer', bufnr('%'))"



