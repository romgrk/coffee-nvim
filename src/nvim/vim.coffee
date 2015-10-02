# !::coffee [../../lib/nvim]

Reflect = require 'harmony-reflect'
hh = require '../helpers'

module.exports =
class VimProxy
    var: 
        get: (target, name) -> Nvim.getVar(name)
        set: (target, name, val) -> Nvim.setVar(name, val)
        deleteProperty: (target, name) ->
            try Nvim.setVar name, null
            catch e 
                return false
            return true

    option:
        get: (target, name) -> Nvim.getOption(name)
        set: (target, name, val) -> Nvim.setOption(name, val)
        deleteProperty: (target, name) ->
            try Nvim.setOption name, ''
            catch e 
                return false
            return true

    constructor: () ->
        vimObject = 
            option: new Proxy {}, @option
            var:    new Proxy {}, @var
        return new Proxy(vimObject, @)

    get: (target, name, receiver) ->
        if (name of target)
            return target[name]
        try
            return hh.res(Nvim.getVvar(name))
        catch error
            return undefined

    set: (target, name, val, receiver) ->
        return false

