# !::coffee [../lib]

# Imports =================================================================={{{

_       = require 'lodash'
Path    = require 'path'
Reflect = require 'harmony-reflect'
sync    = require 'synchronize'
fiber   = sync.fiber
await   = sync.await
defer   = sync.defer

#===========================================================================}}}

module.exports = hh = {}

# Buffer to string conversion
global.RES = hh.res = (object) ->
    if Buffer.isBuffer(object)
        return object.toString()
    return object

# Define super-class of
hh.superClass = (type) ->
    type.__super__ = _.extend({}, type::)

hh.defineProxies = (obj, proxies) ->
    for name, desc of proxies
        obj[name] = new Proxy {}, desc

# Option property descriptor
hh.getOptionDesc = (args...) ->
    optName = args[0]
    context = args[1] ? null
    getFn = -> @getOption optName
    setFn = (v) -> @setOption optName, v
    if context?
        getFn = getFn.bind(context)
        setFn = setFn.bind(context)
    return {get: getFn, set: setFn}
hh.addOptionDesc = (obj, propName, optName) ->
    getFn = -> @getOption optName
    setFn = (v) -> @setOption optName, v
    obj.properties[propName] = 
        get: getFn, set: setFn

# Var property descriptor
hh.getVarDesc = (varName) ->
    getFn = -> @getVar varName
    setFn = (v) -> @setVar varName, v
    return {get: getFn, set: setFn}
hh.addVarDesc = (obj, propName, varName) ->
    getFn = -> @getVar varName
    setFn = (v) -> @setVar varName, v
    obj.properties[propName] = 
        get: getFn, set: setFn
