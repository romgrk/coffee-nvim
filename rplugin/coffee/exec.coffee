# !::exe [CoffeelibPlugin]


onBufEnter = (args) ->
    log.warn args.toString()

#module.define 'autocmd', 'BufEnter', onBufEnter, false, {pattern: '*.coffee', eval: 'expand("<abuf>")'}


undefined
