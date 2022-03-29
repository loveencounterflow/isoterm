



'use strict'



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'XTERM'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
PATH                      = require 'path'
CP                        = require 'child_process'
#...........................................................................................................
xterm_path                = PATH.resolve PATH.join __dirname, '../xterm'
start_path                = PATH.resolve PATH.join __dirname, '../app/start.js'

#-----------------------------------------------------------------------------------------------------------
parse_arguments = ->
  if process.argv.length isnt 2
    warn "^445-1^ this command doesn't accept parameters; terminating"
    process.exit 1

#-----------------------------------------------------------------------------------------------------------
start_server = -> new Promise ( resolve, reject ) =>
  port    = null
  signals =
    webpack:    false
    server:     false
    browser:    false
  #.........................................................................................................
  conclude = ( signal ) =>
    signals[ signal ] = true
    if signals.webpack and signals.server and ( not signals.browser )
      signals.browser = true
      resolve { server, port, }
  #.........................................................................................................
  process.chdir xterm_path
  cp_cfg            = { detached: false, }
  server            = CP.fork start_path, cp_cfg
  #.........................................................................................................
  server.on 'error', ( error ) => warn '^server@445-2^', error
  #.........................................................................................................
  server.on 'message', ( d ) =>
    # info '^server@445-3^', d
    switch d?.$key ? null
      when '^connect'
        port = d.port
        help "^server@445-4^ serving on port #{rpr port}"
        conclude 'server'
      when '^webpack-ready'
        help "^server@445-5^ webpack ready"
        conclude 'webpack'
      when '^term-pid'
        help "^server@445-5^ received terminal PID #{d.pid}"
        demo_websocket d.pid
      else
        warn "^server@445-6^ unknown message format: #{rpr d}"
    return null
  #.........................................................................................................
  server.on 'close',      => whisper '^server@445-7^', 'close'
  server.on 'disconnect', => whisper '^server@445-8^', 'disconnect'
  server.on 'error',      => whisper '^server@445-9^', 'error'
  server.on 'exit',       => whisper '^server@445-10^', 'exit'
  server.on 'message',    => whisper '^server@445-11^', 'message'
  server.on 'spawn',      => whisper '^server@445-12^', 'spawn'
  # help '^445-13^', 'Server started'
  # debug '^445-14^', server.channel
  ### TAINT get or set port ###
  return null

#-----------------------------------------------------------------------------------------------------------
start_browser = ( cfg ) -> new Promise ( resolve, reject ) =>
  defaults    = { port: null, }
  { server
    port }    = { defaults..., cfg..., }
  cmd         = 'chromium'
  ### TAINT get address from `start_server()` ###
  address     = "http://localhost:#{port}"
  parameters  = [ "--app=#{address}", ]
  cp_cfg      = { detached: false, }
  browser     = CP.spawn cmd, parameters, cp_cfg
  browser.on 'error', ( error ) => warn '^browser@445-15^', error
  browser.on 'close',      => whisper '^browser@445-16^', 'close'
  browser.on 'disconnect', => whisper '^browser@445-17^', 'disconnect'
  browser.on 'error',      => whisper '^browser@445-18^', 'error'
  browser.on 'exit',       => whisper '^browser@445-19^', 'exit'; server.kill()
  browser.on 'message',    => whisper '^browser@445-20^', 'message'
  browser.on 'spawn',      => whisper '^browser@445-21^', 'spawn'
  return { browser, }

#-----------------------------------------------------------------------------------------------------------
run = ->
  parse_arguments()
  { server, port, } = await start_server()
  { browser, }      = await start_browser { server, port, }
  return null

#-----------------------------------------------------------------------------------------------------------
demo_websocket = ( pid ) =>
  url     = "ws://localhost:3000/terminals/#{pid}"
  WS      = require 'ws'
  ws      = new WS.WebSocket url
  ws.on 'open', () =>
    urge "^445-23^ websocket open"
    ws.send 'helo from server'
  ws.on 'message', ( data ) =>
    urge "^445-23^ received: #{rpr data}"
  return null


############################################################################################################
do =>
  await run()

  # ws_cfg  =
  #   # backlog:            # {Number} The maximum length of the queue of pending connections.
  #   # clientTracking:     # {Boolean} Specifies whether or not to track clients.
  #   # handleProtocols:    # {Function} A function which can be used to handle the WebSocket subprotocols. See description below.
  #   # host:               # {String} The hostname where to bind the server.
  #   # maxPayload:         # {Number} The maximum allowed message size in bytes. Defaults to 100 MiB (104857600 bytes).
  #   # noServer:           # {Boolean} Enable no server mode.
  #   # path:               # {String} Accept only connections matching this path.
  #   perMessageDeflate:  false # {Boolean|Object} Enable/disable permessage-deflate.
  #   port:               8080 # {Number} The port where to bind the server.
  #   # server:             # {http.Server|https.Server} A pre-created Node.js HTTP/S server.
  #   skipUTF8Validation: true # {Boolean} Specifies whether or not to skip UTF-8 validation for text and close messages. Defaults to false. Set to true only if clients are trusted.
  # ws_server = new WS.WebSocketServer ws_cfg
  # ws_server.on 'connection', ( ws ) =>
  #   ws.on 'message', ( data ) =>
  #     urge "^445-23^ received: #{rpr data}"
  #     ws.send 'something'




