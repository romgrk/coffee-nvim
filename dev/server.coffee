# !::coffee [.]

net      = require 'net'
readline = require 'readline'
logger   = require 'romgrk-logger'
log      = logger(console.log)
log.method = (args...) ->
    process.stdout.write args.join ' '

PORT = 5000

sk = null
clients = []
history = []

# Readline
rd = readline.createInterface
    input: process.stdin
    output: process.stdout
    completer: (line) -> [history[...1], line]

# Server
server = net.createServer (socket) ->
    sk = socket
    clients += socket
    log.a 'Connected: ' + sk.remoteAddress + ': ' + sk.remotePort, '\n'
    socket.on 'data', (d) ->
        log.text log.erase.line + d.toString()
        rd.prompt()
    socket.on 'end', () ->
        sk = null
        log.a 'Disconnected\n'
        rd.prompt()

# Listen
server.listen(PORT)
log.a "Listening on port #{PORT}...\n"

rd.on 'SIGINT', -> process.exit(0)
rd.on 'line', (line) ->
    history.unshift line
    if sk?
        sk.write(line)
    else
        log.a 'No socket\n'
    rd.prompt()
rd.on 'close', ->
    log.warn 'Exiting.'
    process.exit(0)
