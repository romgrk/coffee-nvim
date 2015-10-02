" File: coffeelib.vim
" Author: romgrk
" Description: rcplugin host spawner
" Date: 29 Sep 2015
" Exeline: ::exe [so %]

let COFFEELIB_CHANNEL = -1
let COFFEELIB_DIR     = expand('<sfile>:p:h:h')

function! coffeelib#isChannelActive (num) 
    try
        call rpcnotify(a:num, '', [])
    catch /.*/
        return 0
    endtry
    return 1
endfunction

function! coffeelib#RequireHost (host) 
    let isClone = get(a:host, 'name', '') =~? 'registration-clone'
    if exists('g:COFFEELIB_CHANNEL')
        \ && coffeelib#isChannelActive(g:COFFEELIB_CHANNEL)
        return g:COFFEELIB_CHANNEL
    endif
    
    let dirname = g:COFFEELIB_DIR

    let prog    = 'node'
    let flags   = ['--harmony_proxies']
    let main    = dirname.'/lib/main'

    let args    = flags + [main]

    try
        let channel = rpcstart(prog, args)
        "echo prog . ', ' . string(args)
        
        if !isClone
            let g:COFFEELIB_CHANNEL = channel
        else
            let g:COFFEELIB_CLONE_CHANNEL = channel
        end
         
        sleep 300m
        
        return channel
    catch /.*/
        throw 'Couldnt start coffeelib host ' .
            \ 'with rpcstart(' . prog . ', ' . string(args) . ')' .
            \ ' ' . v:exception
    endtry
endfunction

if exists('g:COFFEELIB_ENABLE')
    call coffeelib#RequireHost([])
    call remote#host#Register('coffee', '*.coffee', function('coffeelib#RequireHost'))
end

if !exists('g:debug')
    finish
end

nmap <F1> :echo 'start: ' . coffeelib#RequireHost([])<CR>
nmap <F2> :echo 'stop: ' . rpcstop(<C-r>=g:COFFEELIB_CHANNEL<CR>)<CR>

function! remote#host#RegisterPlugin(host, path, specs)
    let plugins = remote#host#PluginsForHost(a:host)

    for plugin in plugins
        if plugin.path ==? a:path
            let i = index(plugins, plugin)
            call remove(plugins, i)
            break
        endif
    endfor

    for spec in a:specs
        let type = spec.type
        let name = spec.name
        let sync = spec.sync
        let opts = spec.opts
        let rpc_method = a:path
        if type == 'command'
            let rpc_method .= ':command:'.name
            call remote#define#CommandOnHost(a:host, rpc_method, sync, name, opts)
        elseif type == 'autocmd'
            let rpc_method .= ':autocmd:'.name.':'.get(opts, 'pattern', '*')
            call remote#define#AutocmdOnHost(a:host, rpc_method, sync, name, opts)
        elseif type == 'function'
            let rpc_method .= ':function:'.name
            call remote#define#FunctionOnHost(a:host, rpc_method, sync, name, opts)
        else
            echoerr 'Invalid declaration type: '.type
        endif
    endfor

    call add(plugins, {'path': a:path, 'specs': a:specs})
endfunction

