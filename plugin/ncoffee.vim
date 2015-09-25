" File: start.vim
" Author: romgrk
" Description: rcplugin host spawner
" Date: 18 Sep 2015
" Exeline: !::exe [so %]

let g:COFFEE_NVIM_DIR = expand('<sfile>:p:h:h')

nmap <F1> :call RequireCoffeeHost([])<CR>
nmap <F2> :call rpcstop(<C-r>=g:COFFEE_CHANNEL<CR>)<CR>
nmap <F4> :call remote#host#Register('coffee', '*.coffee', function('RequireCoffeeHost'))<CR>

function! ReloadCoffeeHost () 
    call rpcstop(g:COFFEE_CHANNEL)
    call RequireCoffeeHost([])
endfunction

function! RequireCoffeeHost (host) 
    let dirname = g:COFFEE_NVIM_DIR

    let prog    = 'node'
    let flags   = ['--harmony_proxies']
    let main    = g:COFFEE_NVIM_DIR.'/lib/main'

    let args    = flags + [main]

    try
        let channel = rpcstart('node', args)
        call EchonHL('TextWarning', 'channel=' . channel . ' ')
        "call EchonHL('TextInfo', prog, string(args))
        echohl None
        let g:COFFEE_CHANNEL = channel
        return channel
    catch
        throw 'Couldnt start coffee-nvim host ' .
            \ 'with rpcstart(' . prog . ', ' . string(args) . ')'
    endtry
endfunction
"call remote#host#Register('coffee', '*.coffee', function('RequireCoffeeHost'))
