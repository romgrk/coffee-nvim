# !::exe [RunBuffer]

#log.warning lib.eval('g:LASTSESSION')
#log.warning 'buffer: ', lib.buffer, (typeof lib.buffer)

#log.text 'Buffers:', lib.buffers.length

#log.text m for m of process
#log.inspect process.mainModule

buffer  = lib.buffer
buffers = lib.buffers

#for b in buffers
    #log.text b.number, await b.isValid defer()

log.debug buffer.prototype

nvimKeys = []
nvimKeys.push m for m of Nvim

for m of Nvim.Buffer.prototype
    log.text m
