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

# Define class
hh.superClass = (type) ->
    type.__super__ = _.extend({}, type::)

# Buffer to string
global.RES = hh.res = (object) ->
    if Buffer.isBuffer(object)
        return object.toString()
    return object

hh.addOptionDesc = (obj, propName, optName) ->
    getFn = -> @getOption optName
    setFn = (v) -> @setOption optName, v
    obj.properties[propName] = 
        get: getFn, set: setFn
