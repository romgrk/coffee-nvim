# ::coffee [../lib]

# !::exe [RunBufferInVM]


#apiTypes = [Nvim.constructor, Nvim.Buffer, Nvim.Window, Nvim.Tabpage]
#synchronizeApi = (object) ->
    #list = []
    #for k, v of object::
        #apiFunc = object::[k]?.metadata?
        #continue unless apiFunc
        #func = object::[k]
        #sync object::, k
        #object::[k].metadata = func.metadata
        #list.push k
    #log.b list, '\n'

#synchronizeApi(t) for t in apiTypes

log.info Nvim.getCurrentWindow().getWidth()

Nvim.getCurrentWindow (err, res) ->
    sync.fiber -> log.warn res.getWidth()

