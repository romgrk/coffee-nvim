# !::exe [RunBufferInVM]

_ = require 'lodash'
#echohl 'hello!'

#buf = buffer.proxy()
#log.success buf['&buflisted'], buf[':current_syntax']
#win = window.getProxy()
#log.label 'w', window.width, '\th', window.height
#log.label 'cursor', window.cursor

#for w, i in windows
    #log.label i + ' pos', w.position

define 'command', 'TEST', ->
    echohl 'yay'

module.exports = ->
    return __dirname

bufs = _.filter buffers, (b) -> b.valid
for b in bufs
    log.label b.number, b.name

log.warn __dirname if __dirname?
