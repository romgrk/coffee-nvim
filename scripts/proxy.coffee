# !::exe [RunBuffer]


Reflect = require 'harmony-reflect'

BufferProxy = (target) ->
    return new Proxy target,
        get: (target, name, receiver) ->
            if name.charAt(0) == ':'
                varName = name.substring(1)
                return await target.getVar varName, defer()
            if name.charAt(0) == '&'
                optName = name.substring(1)
                return await target.getOption optName, defer()
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

#VBuffer = () ->
    #@name = 'fbads'
    #@number = 28
    #@['&type'] = 'file'
    #return AttributeProxy(@)
#VBuffer::size = ->
    #log.info 10, 300

#buf = new VBuffer()

#log.info 'name: ',      buf.name

#buf.size()

#log.info '&type: ',     buf['&type']
#log.info 'number: ',    buf['number']

#buf['&ft'] = 'vim'
#log.info '&ft:',        buf['&ft']

