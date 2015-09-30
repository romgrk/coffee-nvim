# !::coffee [../../lib/nvim]

Reflect = require 'harmony-reflect'

module.exports =
class VimProxy
    constructor: () ->
        return new Proxy({}, @)

    get: (target, name, receiver) ->
        if (name of target)
            return target[name]
        try
            return Nvim.getVvar(name)
        catch error
            return undefined

    set: (target, name, val, receiver) ->
        return false
