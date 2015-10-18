# !::coffee [../../lib/nvim]

hh        = require '../helpers'
Functions = require './functions'
Reflect   = require 'harmony-reflect'

hh.superClass(Nvim.Window)

Nvim.Window::getProxy = -> @_proxy ?= new WindowProxy @
Nvim.Window::getCursor = -> new CursorProxy @, super()
Nvim.Window::getBuffer = -> super().getProxy()
Nvim.Window::getTabpage = -> super().getProxy()

# Additionnal methods
Nvim.Window::do = (cmd) ->  
    winnr = @number
    if (not winnr?) or typeof winnr isnt 'number'
        log.warn 'windo: abort: ', winnr
        return
    Nvim.command winnr + 'windo ' + cmd
Nvim.Window::close = ->  
    @do 'close'

class Window
    constructor: (num) ->
        if num? && typeof num is 'number'
            return Nvim.getWindows()[num-1] ? null
        Nvim.command 'new | let g:Window_new = winnr()'
        num = eval 'g:Window_new'
        return Nvim.getWindows()[num-1]

Window.properties =
    number: # FIXME should be done otherwise
        get: ->
            for w, i in Nvim.getWindows()
                return (i+1) if w.equals(this)
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


module.exports = {WindowProxy, Window}
