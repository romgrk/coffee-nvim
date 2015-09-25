# !::exe [RunBuffer]


Reflect = require 'harmony-reflect'

BufferProxy = (target) ->
    return new Proxy target,
        get: (target, name, receiver) ->
            if name.charAt(0) == ':'
                varName = name.substring(1)
                return target.getVar(varName)
            if name.charAt(0) == '&'
                optName = name.substring(1)
                return target.getOption(optName)
            if (name of target) then return target[name]
            return undefined

        set: (target, name, val, receiver) ->
            if name.charAt(0) == ':'
                varName = name.substring(1)
                return await target.getVar varName, defer()
            if name.charAt(0) == '&'
                optName = name.substring(1)
                return await target.getOption optName, defer()
            else
                target[name] = val
            return true

buffer = BufferProxy(lib.buffer)

log.b buffer[':current_syntax']


undefined
