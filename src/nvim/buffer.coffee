# !::coffee [../../lib/nvim]

_       = require 'lodash'
Reflect = require 'harmony-reflect'

class LineProxy
    buffer: null

    constructor: (@buffer, target) ->
        return new Proxy target, @

    get: (target, name, receiver) ->
        if name is 'length'
            return @buffer.lineCount()
        if /^\d+$/.test name
            return @buffer.getLine(~~name).toString()
        if (name of target)
            return target[name]
        return undefined

    set: (target, name, val, receiver) ->
        if /^\d+$/.test name
            @buffer.setLine(~~name, val)
        return true

    deleteProperty: (target, name) ->
        if /^\d+$/.test name
            try @buffer.delLine(~~name)
            catch e
                return false
            return true
        return Reflect.deleteProperty target, name

BufferObject = {}

BufferObject.properties =
    length:
        get: -> return @lineCount()
    number:
        get: -> return @getNumber()
    name:
        get: -> return @getName()
        set: (v) -> @setName(v)
    valid:
        get: -> return @isValid()
    listed:
        get: -> return @getOption('buflisted')
        set: (v) -> @setOption('buflisted', v)
    type:
        get: -> return @getOption('buftype')
        set: (v) -> @setOption('buftype', v)

BufferObject.methods = 
    delete: ->
        Nvim.command 'bdelete ' + @number
    wipeout: ->
        Nvim.command 'bwipeout ' + @number

module.exports =
class BufferProxy
    @LineProxy: LineProxy

    constructor: (buffer) ->
        _.extend buffer, BufferObject.methods
        Object.defineProperties(buffer, BufferObject.properties)
        buffer.lines = new LineProxy(buffer, {})
        return new Proxy buffer, @

    get: (target, name, receiver) ->
        switch name.charAt(0)
            when ':'
                varName = name.substring(1)
                return target.getVar(varName)
            when '&'
                optName = name.substring(1)
                return target.getOption(optName)
        if /^\d+$/.test name
            return target.getLine(~~name).toString()
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

