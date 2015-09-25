# !::coffee [../lib]

Reflect = require 'harmony-reflect'

module.exports = Tabpage =
    init: (type) ->
        for key, definition of @properties
            Object.defineProperty type, key, definition
        type.getProxy = ->
            return new TabpageProxy @

Tabpage.properties =
    window:
        get: -> return @getWindow()
    windows:
        get: -> return @getWindows()
    valid:
        get: -> return @isValid()

class TabpageProxy
    constructor: (target) ->
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


