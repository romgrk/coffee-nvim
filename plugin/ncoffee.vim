" File: start.vim
" Author: romgrk
" Description: rcplugin host spawner
" Date: 18 Sep 2015
" Exeline: !::exe [so %]

let g:COFFEE_NVIM_DIR = expand('<sfile>:p:h:h')

function! ReloadCoffeeHost () 
    call rpcstop(g:COFFEE_CHANNEL)
    call RequireCoffeeHost([])
endfunction

function! IsChannelActive (num) 
    try
        call rpcnotify(a:num, '', [])
    catch /.*/
        return 0
    endtry
    return 1
endfunction

function! RequireCoffeeHost (host) 
    if IsChannelActive(g:COFFEE_CHANNEL)
        return g:COFFEE_CHANNEL
    endif
    
    let dirname = g:COFFEE_NVIM_DIR

    let prog    = 'node'
    let flags   = ['--harmony_proxies']
    let main    = dirname.'/lib/main'

    let args    = flags + [main]

    try
        let channel = rpcstart('node', args)
        call EchoHL('TextWarning', 'channel=' . channel . ' ')
        let g:COFFEE_CHANNEL = channel
        return channel
    catch
        throw 'Couldnt start coffee-nvim host ' .
            \ 'with rpcstart(' . prog . ', ' . string(args) . ')'
    endtry
endfunction
call remote#host#Register('coffee', '*.coffee', function('RequireCoffeeHost'))

if !exists('g:debug')
    finish
end

nmap <F1> :call RequireCoffeeHost([])<CR>
nmap <F2> :call rpcstop(<C-r>=g:COFFEE_CHANNEL<CR>)<CR>
nmap <F3> :call rpcstop(<C-r>=g:COFFEE_CHANNEL<CR>)<CR>

function! remote#host#RegisterPlugin(host, path, specs)
  let plugins = remote#host#PluginsForHost(a:host)

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


