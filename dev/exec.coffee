# !::coffee [.]

log = require 'romgrk-logger'

log.warning set('cpo?')
log.success eval('@@')
log.warning eval('g:LASTSESSION')

execute '2wincmd w'
#insert 0, ['hello']

log.warning 'buffer: ', buffer, (typeof buffer)

defineObjects()

for b in buffers
    log.success b.number + ': ' + b.name
#buffer.name = 'HAHAHAH'

