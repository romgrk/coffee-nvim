" File: start.vim
" Author: romgrk
" Description: rcplugin host spawner
" Date: 18 Sep 2015
" !::exe [so % | call CoffeeHost()]


function! CoffeeHost () 
    return
    if get(g:, 'COFFEE_HOST_CHANNEL', 0) | try
        call rpcstop(g:COFFEE_HOST_CHANNEL)
        catch /.*/
            call EchoHL('TextWarning',
            \ 'Error trying to stop previous rpc-channel: ',
            \ v:error)
    endtry|end

    let dirname = expand('<sfile>:p:h:h')
    let flags   = ['--harmony_proxies']
    let main    = dirname.'/lib/main'

    let file    = 'node'
    let args    = flags + [main]

    call EchoHL('TextInfo', 'Starting... ',
                \ 'program: ', file,
                \ '; args: ', string(args))

    try | let channel = rpcstart(file, args)
    catch | call EchoHL('TextError',
        \ 'Error trying to spawn rpc-host: ',
        \ v:error) | return | endtry

    let g:COFFEE_HOST_CHANNEL = channel

    call rpcnotify(s:channel, 'hello', 'world')

    let @c="call rpcstop(" . s:channel . ")"
endfunction

