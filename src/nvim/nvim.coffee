# !::coffee [../../lib/nvim]

_       = require 'lodash'
hh      = require '../helpers'

Reflect = require 'harmony-reflect'

Nvim = global.Nvim
Nvim.super = _.extend({}, Nvim)

Nvim.getCurrentBuffer = -> @super.getCurrentBuffer().getProxy()
Nvim.getCurrentWindow = -> @super.getCurrentWindow().getProxy()
Nvim.getCurrentTabpage = -> @super.getCurrentTabpage().getProxy()

Nvim.getBuffers = -> _.map @super.getBuffers(), (e) -> e.getProxy()
Nvim.getWindows = -> _.map @super.getWindows(), (e) -> e.getProxy()
Nvim.getTabpages = -> _.map @super.getTabpages(), (e) -> e.getProxy()

module.exports = Nvim
