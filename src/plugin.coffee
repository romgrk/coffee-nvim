# !::coffee [../lib]

Fs           = require 'fs'
Vm           = require 'vm'
Path         = require 'path'
Module       = require 'module'
CoffeeScript = require 'coffee-script'

assert = require 'assert'

class Plugin extends Module

    @_types:   ['command', 'function', 'autocmd']
    @_context: {}
    @_cache:   {}

    # Find module
    @_resolveFilename: (f, p) ->
        f = f.toString() if typeof f isnt 'string'
        super(f, p)

    # Load module
    @_load = (filename, context) ->
        try
            filename = @_resolveFilename filename, process.mainModule
        catch e
            log.error e.stack
            return undefined
        if Plugin._cache[filename]?
            return Plugin._cache[filename]
        p = new Plugin(filename)
        p.load(context ? null)
        return p

    ### INSTANCE ###

    # Full path & specs
    filename:  null
    specs:     []
    handlers:  {}

    constructor: (filename) ->
        @filename = @constructor._resolveFilename filename, @
        @dirname  = Path.dirname @filename

    load: (context) ->
        if Plugin._cache[@filename]?
            return Plugin._cache[@filename]
        
        @paths = Module._nodeModulePaths @filename
        extension = Path.extname @filename
        
        require = (path) =>
            @require path
        require.resolve = (req) =>
            Module._resolveFilename req, @
        
        context ?= Plugin._context ? {}
        context.__filename = @filename
        context.__dirname  = @dirname
        context.module  = this
        context.require = require.bind(@)
        context.define  = @define.bind(@)
        
        sandbox = Vm.createContext context
        if extension is '.coffee'
            code = CoffeeScript._compileFile @filename
        else
            code = Fs.readFileSync @filename
        code = Module.wrap code
        
        compiled = Vm.runInContext code, sandbox
        exports  = compiled.apply(@exports, [@exports, require, @, @filename, @dirname])
        
        Plugin._cache[@filename] = this
        @loaded = true
         
        return exports

    define: (type, name, cb, sync=false, opts={}) ->
        if typeof sync is 'object'
            opts = sync
            sync = opts.sync ? false
        assert type? && name? && cb?
        assert typeof type is 'string'
        assert Plugin._types.indexOf(type) != -1
        assert typeof name is 'string'
        assert typeof cb is 'function'
        spec =
            type: type,
            name: name,
            sync: sync
            opts: opts
        if type is 'autocmd'
            @handlers["#{type}:#{name}:#{opts.pattern ? '*'}"] = cb
        else
            @handlers["#{type}:#{name}"] = cb
        @specs.push spec

module.exports = Plugin
