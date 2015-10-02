# !::coffee [../lib/]

# Imports =================================================================={{{

_    = require 'lodash'
Net  = require 'net'
Path = require 'path'
Fs   = require 'fs'
Vm   = require 'vm'

CoffeeScript = require 'coffee-script'
Reflect      = require 'harmony-reflect'
attach       = require 'neovim-client'

Logger = require 'romgrk-logger'
util   = require 'util'

Plugin = require './plugin'

sync   = require 'synchronize'
fiber  = sync.fiber
await  = sync.await
defer  = sync.defer

# }}}
# Settings ================================================================={{{

# Stdio for msgpack data transfer
stdio = [process.stdout, process.stdin]

# Log server
PORT = 5000
sock = null

#===========================================================================}}}

# Nvim instance
Nvim      = null
coffeelib = null
loaded    = false

# List of commands
commands = {}

# Socket data
dataHandler = (data) ->
    data = data.toString().trim()
    try
        code = CoffeeScript.compile data, bare: true
    catch e
        log.error e.stack
        return
    fiber -> vmHandler(code)

# Vm run
vmHandler = (code) ->
    try
        context = coffeelib
        context._       = _
        context.log     = log
        context.sync    = sync
        context.require = require
        context.process = process
        sandbox = Vm.createContext context
        res = Vm.runInContext(code, sandbox)
        if res?
            if typeof res is 'object'
                log.debug util.inspect(res, depth:1)
            else
                log.debug res
    catch e
        log.error e, e.stack

# RPC request/notification

onNvimNotification = (method, args) ->
    log.info 'Notification: ', method, args.toString()
    return if method is ''
    if commands[method]?
        fiber -> commands[method] args...
    else
        fiber -> callHandler(method, args)

onNvimRequest = (method, args, resp) ->
    if method is 'poll'
        resp.send 'ok'
        return
    if method is 'specs'
        getSpecs args[0], resp
        return 
    log.info 'Request: ', method, args.toString()
    try
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
    rest     = data[1..].join(':')
    try
        plugin = Plugin._load(filename)
        if plugin?
            handler = plugin.handlers[rest]
            rv = handler.apply plugin, args
            resp?.send rv
        else
            log.warning 'Plugin not found: ' + filename
            resp.send 'Plugin not found', true if resp?
    catch e
        log.err method, args, e.stack
        resp.send e.toString(), true if resp?

getSpecs = (filename, resp) ->
    try
        plugin = Plugin._load filename
        if plugin?
            plugin.specs ?= []
            resp.send(plugin.specs)
            log.success 'specs: '+filename, plugin.specs
            #log.inspect plugin
        else
            resp.send false
    catch e
        resp.send false
        log.error 'SPECS:'+filename
        log.error e.stack

# Plugin: commands

commands['CoffeelibPlugin'] = (file) ->
    try
        if Plugin._cache[file]?
            delete Plugin._cache[file]
        p = new Plugin file
        p.load(coffeelib)
        global.res = p.exports
    catch e
        log.error e, e.stack

commands['CoffeelibRun'] = (file) ->
    try
        content = Fs.readFileSync(file).toString()
        code = CoffeeScript.compile(content, bare: true)
        vmHandler(code)
    catch e
        log.error e, e.stack

# Define command
defineCommand = (name) ->
    def = "command! #{name} call rpcnotify(#{Nvim._channel_id},"
    def += " '#{name}', expand('%:p'))"
    Nvim.command(def)


# Log server
sock = Net.createConnection PORT
sock.on 'data', dataHandler
global.log = log  = Logger(console.log)
log.method = (args...) -> sock.write args.join(' ')+'\n'

# Nvim pairing
attach stdio[0], stdio[1], (err, nvim) ->
    if err
        log.error 'Couldnt initiate nvim', err.stack
        return
    try
        hostSetup(nvim)
    catch e
        log.error 'Couldnt setup host', e.stack

# Main setup
hostSetup = (nvim) ->
    global.Nvim = Nvim = nvim
    Nvim.on 'request',      onNvimRequest
    Nvim.on 'notification', onNvimNotification
    Nvim.on 'disconnect',   onNvimDisconnect
    
    # Coffeelib
    coffeelib = require('./coffeelib')
    coffeelib.log = log
    
    Plugin._context = coffeelib

    log.success 'connected to neovim, channel=' + Nvim._channel_id
    
    loaded = true
    
    for c of commands
        log.info 'Defining ' + c
        defineCommand(c)




