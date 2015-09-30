# !::coffee [../../lib/nvim]

Reflect = require 'harmony-reflect'

module.exports = 
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

