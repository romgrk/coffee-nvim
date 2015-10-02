# !::exe [CoffeelibPlugin]

onBufEnter = (args) ->
    log.warn 'BufEnter', __filename, ' ('+args.toString()+')'

module.define 'autocmd', 'BufEnter', onBufEnter,
    {pattern: __filename, eval: 'expand("<abuf>")'}

log.warn __dirname

undefined
