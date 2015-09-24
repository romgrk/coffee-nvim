# !::coffee [.]

_        = require 'lodash'
Compiler = require 'coffeescript-compiler'
Sync     = require './sync'

cc = new Compiler
Sync.returnAll cc, 'compile'
module.exports = _.bind cc.compile, cc, _,  {bare: true}

