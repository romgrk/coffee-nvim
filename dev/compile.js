// Generated by CoffeeScript 1.10.0
(function() {
  var Compiler, Sync, _, cc;

  _ = require('lodash');

  Compiler = require('coffeescript-compiler');

  Sync = require('./sync');

  cc = new Compiler;

  Sync.returnAll(cc, 'compile');

  module.exports = _.bind(cc.compile, cc, _, {
    bare: true
  });

}).call(this);
