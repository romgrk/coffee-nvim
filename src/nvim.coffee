# !::coffee [../lib]

# Imports =================================================================={{{

_       = require 'lodash'
Path    = require 'path'
Reflect = require 'harmony-reflect'
sync    = require '../dev/sync'
fiber   = sync.fiber
await   = sync.await
defer   = sync.defer

#===========================================================================}}}

module.exports = lib =
    context: null

    init: (nvim) ->
        #NvimType = () ->
            #@name = 'nvim_type'
        #NvimType:: = new nvim.constructor(nvim._session)
        #Nvim = new NvimType
        Nvim = nvim
        @synchronize Nvim

        #types = [Nvim.constructor, Nvim.Buffer, Nvim.Window, Nvim.Tabpage]
        #@synchronize(t) for t in types
        @buffer = require('./buffer')
        @buffer.init(Nvim.Buffer::)
        @synchronize Nvim.Buffer::

        @window = require('./window')
        @window.init(Nvim.Window::)
        @synchronize Nvim.Window::

        @tabpage = require('./tabpage')
        @tabpage.init(Nvim.Tabpage::)
        @synchronize Nvim.Tabpage::

        context = require('./global')(Nvim)
        context.Nvim = Nvim
        @context = context

        return context

    synchronize: (object) ->
        for k, v of object
            apiFunc = object[k]?.metadata?
            continue unless apiFunc
            func = object[k]
            sync object, k
            object[k].metadata = func.metadata

