# !::coffee [../../lib/nvim]

Reflect = require 'harmony-reflect'
hh      = require '../helpers'

hh.superClass(Nvim.Window)

#Nvim.Window::getOption = (args...) -> RES super(args...)

Nvim.Window::getProxy = -> @_proxy ?= new WindowProxy @
Nvim.Window::getCursor = -> new CursorProxy @, super()
Nvim.Window::getBuffer = -> super().getProxy()
Nvim.Window::getTabpage = -> super().getProxy()

Window = {}
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
    status: hh.getOptionDesc 'statusline'


module.exports =
class WindowProxy
    constructor: (target) ->
        Object.defineProperties target, Window.properties
        return new Proxy target, @

    get: (target, name, receiver) ->
        switch name.charAt(0)
            when ':'
                varName = name.substring(1)
                return target.getVar(varName)
            when '&'
                optName = name.substring(1)
                return target.getOption(optName)
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
        else
            target[name] = val
        return true



