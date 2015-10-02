# !::coffee [../../lib/nvim]

Reflect = require 'harmony-reflect'
hh      = require '../helpers'

class VimProxy
    get: (target, name, receiver) ->
        return target[name] if (name of target)
        try
            return hh.res(Nvim.getVvar(name))
        catch error
            return undefined
    set: (target, name, val, receiver) ->
        if (name of target)
            target[name] = val
            return true
        return false

    constructor: () ->
        vimObject =
            var:    new VarProxy
            option: new OptionProxy
        Object.defineProperties vimObject, @properties
        return new Proxy(vimObject, @)
    
    properties:
        paths: get: Nvim.listRuntimePaths()

class VarProxy
    constructor: (target={}) ->
        return new Proxy target, @
    get: (target, name) -> Nvim.getVar(name)
    set: (target, name, val) -> Nvim.setVar(name, val)
    deleteProperty: (target, name) ->
        try Nvim.setVar name, null
        catch e 
            return false
        return true

class OptionProxy
    constructor: (target={}) ->
        return new Proxy target, @
    get: (target, name) -> Nvim.getOption(name)
    set: (target, name, val) -> Nvim.setOption(name, val)
    deleteProperty: (target, name) ->
        try Nvim.setOption name, ''
        catch e 
            return false
        return true

class CursorProxy
    window: null
    constructor: (@window, cursor) ->
        return new Proxy cursor, @
    
    get: (target, name, receiver) ->
        if name is 'line'
            return target[0]
        if name is 'row'
            return target[1]
        if (name of target)
            return target[name]
        return undefined

    set: (target, name, val, receiver) ->
        if name is 'line' || name is '0'
            @window.setCursor [val, target[1]]
        else if name is 'row' || name is '1'
            @window.setCursor [target[0], val]
        else
            target[name] val
        return true

class CurrentProxy
    constructor: (target={}) ->
        Object.defineProperties target, @properties
        return new Proxy(target, this)

    properties:
        buffer: 
            get: -> Nvim.getCurrentBuffer()
            set: (b) -> Nvim.setCurrentBuffer b
        window:
            get: -> Nvim.getCurrentWindow()
            set: (b) -> Nvim.setCurrentWindow b
        tab:
            get: -> Nvim.getCurrentTabpage()
            set: (b) -> Nvim.setCurrentTabpage b

module.exports = {VimProxy, CursorProxy, VarProxy, OptionProxy, CurrentProxy}
