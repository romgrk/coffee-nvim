# !::coffee [../../lib/nvim]

_       = require 'lodash'
hh      = require '../helpers'
Reflect = require 'harmony-reflect'

Nvim      = global.Nvim
Functions = require './functions'
call      = Functions.call

synIDtrans = (id) -> 
    tId = call.synIDtrans(id)
    return if tId is 0 then undefined else tId

synIDattr = (args...) -> 
    attr = hh.res call.synIDattr(args...)
    if attr == '' or !attr?
        return undefined
    return attr

hlGet = (id, args...) ->
    return synIDattr(synIDtrans(id), args...)

ATTRIBUTES = [
    'bold', 'italic', 'reverse', 
    'standout', 'underline', 'undercurl'
]

SYN_ID  = (name) ->
    return name if typeof name is 'number'
    return undefined if (id = call.hlID name) is 0
    return id
HL_ID   = (name) -> 
    return name if typeof name is 'number'
    return undefined if (id = call.hlID name) is 0
    return synIDtrans(id)
HL_FG   = (id) -> hlGet(id, 'fg')
HL_BG   = (id) -> hlGet(id, 'bg')
HL_ATTR = (id) -> 
    for attr in ATTRIBUTES
        return attr if hlGet(id, attr)?
    return undefined

class Highlight
    @ID: (name) -> 
        HL_ID(name)

    @fg: (id) -> 
        id = HL_ID id
        HL_FG(id)

    @bg: (id) -> 
        id = HL_ID id
        HL_BG(id)

    @attr: (id) -> 
        id = HL_ID id
        HL_ATTR(id)
        
    @find: (name) ->
        id = HL_ID name
        return undefined unless id?
        group = new Highlight.Group(name)
        group.ID   = id
        group.fg   = HL_FG id
        group.bg   = HL_BG id
        group.attr = HL_ATTR id
        return group

    @create: (name, params...) ->
        group = new Highlight.Group(name, params...)

class Highlight.Group
    ID: null
    name: null
    # fg, bg, attr
    constructor: (@name, params...) ->
        if params.length is 1 && _.isObject(params[0])
            params = params[0]
            @fg   = params.fg   ? null
            @bg   = params.bg   ? null
            @attr = params.attr ? null
        else
            params[0] ?= null
            params[1] ?= null
            params[2] ?= null
            [@fg, @bg, @attr] = params



module.exports = {Highlight}
