

let s:sdir = expand('<sfile>:p:h')
let s:scriptname = s:sdir . '/lib/main'

let s:channel = rpcstart('node', [s:scriptname])

call rpcnotify(s:channel, 'hello', 'world')

let @c="call rpcstop(" . s:channel . ")"


