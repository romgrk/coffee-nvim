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

Plugin = require './plugin'
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

# Nvim instance
Nvim = null
lib  = null
clib = null

# List of handlers for nvim requests
handlers = {}

evalMethod = null

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
    fiber ->
        try
            context         = clib
            context._       = _
            context.log     = log
            context.sync    = sync
            context.require = require
            sandbox = Vm.createContext context
            Vm.runInContext code, sandbox
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
    try
        log.info 'Request: ', method, args.toString()
        if method is 'specs'
            filename = args[0]
            plugin = Plugin._load filename
            _.extend handlers, plugin.handlers
            resp.send(plugin.specs ? [])
        else
            resp.send 'nop', true
    catch e
        log.error e.stack
        resp.send e.toString(), true

handlers['plugin'] = (file) ->
    try
        #file = clib.bufname(nr)
        Plugin._load file
    catch e
        log.error e, e.stack

handlers['vm'] = (file) ->
    try
        #file = clib.bufname(nr)
        content = Fs.readFileSync file
        [status, code] = coffee(content)
        vmHandler(code) if status == 0
        throw new Error("couldnt compile "+file) if status == 1
    catch e
        log.error e, e.stack

handlers['eval'] = (file) ->
    try
        #file = clib.bufname(nr)
        content = Fs.readFileSync file
        [status, code] = coffee(content)
        evalHandler(code) if status == 0
        throw new Error("couldnt compile "+file) if status == 1
    catch e
        log.error e, e.stack

defineHandler = (c, h) ->
    def = "com! #{c} call rpcnotify(#{Nvim._channel_id}, '#{h}', expand('%:p'))"
    Nvim.command def

# Log server
sock.on 'data', dataHandler
log.method = (args...) -> sock.write args.join(' ')+'\n'

fiber ->
    Nvim = await attach stdio[0], stdio[1], defer()
    if Nvim instanceof Error
        log.error 'error connecting to neovim: ' + err
        process.exit(1)

    global.log = log
    log.success 'connected to neovim, channel=' + Nvim._channel_id

    Nvim.on 'request', onNvimRequest
    Nvim.on 'notification', onNvimNotification

    try
        lib = require('./nvim')
        clib = lib.init(Nvim)
        clib.log = log

        Plugin._context = lib.context
    catch e
        log.error e.stack

    defineHandler('RunBuffer',     'eval')
    defineHandler('RunBufferInVM', 'vm')
    defineHandler('CoffeePlugin',  'plugin')


