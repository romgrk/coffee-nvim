# !::coffee [.]

Sync     = require 'synchronize'
Fiber    = Sync.Fiber
fiber    = Sync.fiber
await    = Sync.await
defer    = Sync.defer

module.exports = Sync

# Comment
Sync.deferAll = () ->
  deferFunc = defer()
  return (args...) ->
    deferFunc null, args

Sync.returnAllFn = (fn) ->
  return fn if fn._synchronized
  syncFunc = (args...) ->
    if Fiber.current && typeof args[-1..][0] isnt 'function'
      fn.call this, args..., Sync.deferAll()
      return Sync.await()
    else
      return fn.apply this, args
  syncFunc._synchronized = true
  return syncFunc

Sync.returnAll = (obj, fns...) ->
  obj[f] = Sync.returnAllFn(obj[f]) for f in fns
