# !::coffee [../lib]

Reflect = require 'harmony-reflect'

module.exports = Window =
    init: (type) ->
        for key, definition of @properties
            Object.defineProperty type, key, definition
        type.getProxy = ->
            return new WindowProxy @

Window.properties =
    buffer:
        get: -> return @getBuffer()
    width:
        get: -> return @getWidth()
        set: (v) -> @setWidth(v)
    height:
        get: -> return @getHeight()
        set: (v) -> @setHeight(v)
    cursor:
        get: -> return @getCursor()
        set: (v) -> @setCursor(v)
    position:
        get: -> return @getPosition()
    tabpage:
        get: -> return @getTabpage()
    valid:
        get: -> return @isValid()

class WindowProxy
    constructor: (target) ->
        return new Proxy target, @

    get: (target, name, receiver) ->
        switch name.charAt(0)
            when ':'
                varName = name.substring(1)
                return target.getVar(varName)
            when '&'
                optName = name.substring(1)
                return target.getOption(optName)
        if /^\d+$/.test name
            return target.getLine(parseInt name)
        if (name of target)
            return target[name]
        return undefined

    set: (target, name, val, receiver) ->
        if name.charAt(0) == ':'
            varName = name.substring(1)
            target.setVar(varName, val)
        else if name.charAt(0) == '&'
            optName = name.substring(1)
            target.setOption(optName, val)
        else if /^\d+$/.test name
            target.setLine(parseInt(name), val)
        else
            target[name] = val
        return true



