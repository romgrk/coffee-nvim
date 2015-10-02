# !::coffee [../../lib/nvim]

Reflect = require 'harmony-reflect'

hh = require '../helpers'

hh.superClass(Nvim.Tabpage)

Nvim.Tabpage::getProxy = -> @_proxy ?= new TabpageProxy @
Nvim.Tabpage::getWindow = -> super().getProxy()
Nvim.Tabpage::getWindows = -> _.map super(), (e) -> e.getProxy()

Tabpage = {}
Tabpage.properties =
    window:
        get: -> return @getWindow()
    windows:
        get: -> return @getWindows()
    valid:
        get: -> return @isValid()

module.exports = 
class TabpageProxy
    constructor: (target) ->
        Object.defineProperties target, Tabpage.properties
        return new Proxy target, @

    get: (target, name, receiver) ->
        if name.charAt(0) == ':'
            varName = name.substring(1)
            return target.getVar(varName)
        if (name of target)
            return target[name]
        return undefined

    set: (target, name, val, receiver) ->
        if name.charAt(0) == ':'
            varName = name.substring(1)
            target.setVar(varName, val)
        else
            target[name] = val
        return true


