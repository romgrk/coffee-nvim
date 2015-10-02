# !::coffee [../../lib/nvim]

_       = require 'lodash'
hh      = require '../helpers'

Reflect = require 'harmony-reflect'

Nvim = global.Nvim
Nvim:: = Object.getPrototypeOf Nvim

hh.superClass(Nvim::constructor)

Nvim::getCurrentBuffer = -> super().getProxy()
Nvim::getCurrentWindow = -> super().getProxy()
Nvim::getCurrentTabpage = -> super().getProxy()

Nvim::getBuffers = -> _.map super().getProxy()
Nvim::getWindows = -> _.map super().getProxy()
Nvim::getTabpages = -> _.map super().getProxy()


module.exports = Nvim
