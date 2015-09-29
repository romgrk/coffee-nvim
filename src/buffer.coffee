# !::coffee [../lib]

Reflect = require 'harmony-reflect'

module.exports = buffer =

    BufferProxy: BufferProxy

    init: (type) ->
        for key, definition of @properties
            Object.defineProperty type, key, definition
        type.getProxy = type.proxy = ->
            return new BufferProxy @

buffer.properties =
    length:
        get: -> return @lineCount()
    number:
        get: -> return @getNumber()
    name:
        get: -> return @getName()
        set: (v) -> @setName(v)
    valid:
        get: -> return @isValid()

buffer.proxy =
    construct: (target, args) ->
        t = new target(args...)
        return new BufferProxy(t)

class BufferProxy
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
            return target.getLine(~~name)
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
            target.setLine(~~name, val)
        else
            target[name] = val
        return true

    deleteProperty: (target, name) ->
        if /^\d+$/.test name
            try target.delLine(~~name)
            catch e
                return false
            return true
        return Reflect.deleteProperty target, name

