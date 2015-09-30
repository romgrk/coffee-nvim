# !::coffee [../lib/]

# Imports =================================================================={{{

_    = require 'lodash'
Net  = require 'net'
Path = require 'path'
Fs   = require 'fs'
Vm   = require 'vm'

CoffeeScript = require 'coffee-script'

Reflect = require 'harmony-reflect'
attach  = require 'neovim-client'

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
global.log = log

argv.s ?= false

PORT = 5000
sock = Net.createConnection PORT

#===========================================================================}}}

# Nvim instance
Nvim      = null
lib       = null
coffeelib = null

# List of handlers for nvim requests
commands = {}

# Stdio for msgpack data transfer
stdio = [process.stdout, process.stdin]
if argv.s == true
    nvimSocket = Net.createConnection port:6666
    stdio = [nvimSocket, nvimSocket]

# Socket data
dataHandler = (data) ->
    data = data.toString().trim()

    coffee data, (status, code) ->
        if status == 0
            fiber -> vmHandler(code)
        else
            log.error 'couldnt compile: ', data

# Vm run
vmHandler = (code) ->
    try
        context = coffeelib
        context._       = _
        context.log     = log
        context.sync    = sync
        context.require = require
        sandbox = Vm.createContext context
        res = Vm.runInContext(code, sandbox)
        if res?
            log.debug res
    catch e
        log.error e, e.stack

# RPC request/notification commands
onNvimNotification = (method, args) ->
    log.info 'Notification: ', method, args.toString()
    if commands[method]?
        fiber -> commands[method] args...
    else
        fiber -> callHandler(method, args)

onNvimRequest = (method, args, resp) ->
    log.info 'Request: ', method, args.toString()
    try
        if method is 'specs'
            return getSpecs args[0], resp
        else
            callHandler(method, args, resp)
    catch e
        log.error e.stack
        return resp.send e.toString(), true
    return resp.send 'noaction', true

onNvimDisconnect = () ->
    log.error 'Nvim session closed'

callHandler = (method, args, resp) ->
    data     = method.split ':'
    filename = data[0]
    rest     = data[1..]
    try
        plugin = Plugin._load(filename)
        if plugin?
            handler = plugin.handler[rest]
            rv = handler.apply plugin, args
            resp.send rv
        else
            log.warning 'Plugin not found: ' + filename
            resp.send 'Plugin not found', true if resp?
    catch e
        log.err method, args, e.stack
        resp.send e.toString(), true if resp?

getSpecs = (filename, resp) ->
    try
        log.success 'specs: ' + filename
        plugin = Plugin._load filename
        log.inspect plugin
        if plugin?
            return resp.send(plugin.specs ? [])
    catch e
        log.error e.stack
        return resp.send e.toString(), true
    resp.send('Coffee-nvim: file found: ' + filename, true)

# Plugin-defined commands

commands['CoffeePlugin'] = (file) ->
    try
        if Plugin._cache[file]?
            delete Plugin._cache[file]
        p = new Plugin file
        p.load(lib.context)
        global.res = p.exports
    catch e
        log.error e, e.stack

commands['RunBufferInVM'] = (file) ->
    try
        content = Fs.readFileSync file
        [status, code] = coffee(content)
        vmHandler(code) if status == 0
        throw new Error("couldnt compile "+file) if status == 1
    catch e
        log.error e, e.stack

commands['RunBuffer'] = (file) ->
    try
        content = Fs.readFileSync file
        [status, code] = coffee(content)
        evalHandler(code) if status == 0
        throw new Error("couldnt compile "+file) if status == 1
    catch e
        log.error e, e.stack

defineCommand = (name) ->
    def = "com! #{name} call rpcnotify(#{Nvim._channel_id}, '#{name}', expand('%:p'))"
    Nvim.command def

# Log server
sock.on 'data', dataHandler
log.method = (args...) -> sock.write args.join(' ')+'\n'

fiber ->
    try
        Nvim = await attach stdio[0], stdio[1], defer()

        lib = require('./setup')
        coffeelib = lib.init(Nvim)
        coffeelib.log = log
    catch e
        log.error 'Couldnt initiate coffeelib', e.stack
        process.exit 1

    log.success 'connected to neovim, channel=' + Nvim._channel_id

    Nvim.on 'request',      onNvimRequest
    Nvim.on 'notification', onNvimNotification
    Nvim.on 'disconnect',   onNvimDisconnect

    defineCommand(c) for c in commands

    Plugin._context = lib.context



