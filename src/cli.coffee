



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
H                         = require './helpers'
port_pattern              = /^33[0-9]{3}$/
# port_pattern              = /^8081$/
GUY                       = require 'guy'


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
  port              = await H.find_free_port { port: port_pattern, fallback: null, }
  env               = { process.env..., xxterm_port: port, }
  cp_cfg            = { detached: false, env, }
  # cp_cfg            = { detached: false, }
  process.on 'uncaughtException', ( error ) =>
    warn '^cli/server@445-1^', error
    process.exit 99
  try
    server            = CP.fork start_path, cp_cfg
  catch error
    warn '^445-9871^', error
  # server.stderr.on 'data', ( data ) => warn '^445-87^', CND.reverse data
  # server.stdout.on 'data', ( data ) => info '^445-87^', CND.reverse data
  # debug '^5345^', server.stderr.toString().trim()
  #.........................................................................................................
  server.on 'error', ( error ) => warn '^cli/server@445-2^', error
  #.........................................................................................................
  server.on 'message', ( d ) =>
    # info '^cli/server@445-3^', d
    switch d?.$key ? null
      when '^connect'
        help "^cli/server@445-4^ serving on port #{rpr d.port}"
        conclude 'server'
      when '^webpack-ready'
        help "^cli/server@445-5^ webpack ready"
        conclude 'webpack'
      when '^term-pid'
        help "^cli/server@445-6^ received terminal PID #{d.pid}"
        demo_websocket port, d.pid
      else
        warn "^cli/server@445-7^ unknown message format: #{rpr d}"
    return null
  #.........................................................................................................
  server.on 'close',      => whisper '^cli/server@445-8^', 'close'
  server.on 'disconnect', => whisper '^cli/server@445-9^', 'disconnect'
  server.on 'error',      => whisper '^cli/server@445-10^', 'error'
  server.on 'message',    => whisper '^cli/server@445-11^', 'message'
  server.on 'spawn',      => whisper '^cli/server@445-12^', 'spawn'
  server.on 'exit',       => whisper '^cli/server@445-13^', 'exit'; process.exit 0
  #.........................................................................................................
  GUY.process.on_exit ->
    info CND.reverse " ^409-1^ process exiting; terminating server process PID #{server.pid} "
    server.kill()
  #.........................................................................................................
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
  help '^cli/browser@445-14^', "spawning #{cmd} #{parameters.join ' '}"
  browser     = CP.spawn cmd, parameters, cp_cfg
  browser.on 'error', ( error ) => warn '^cli/browser@445-14^', error
  browser.on 'close',       => whisper '^cli/browser@445-15^', 'close'
  browser.on 'disconnect',  => whisper '^cli/browser@445-16^', 'disconnect'
  browser.on 'error',       => whisper '^cli/browser@445-17^', 'error'
  browser.on 'message',     => whisper '^cli/browser@445-18^', 'message'
  browser.on 'spawn',       => whisper '^cli/browser@445-19^', 'spawn'
  browser.on 'exit',        => whisper '^cli/browser@445-20^', 'exit'; process.exit 0
  #.........................................................................................................
  GUY.process.on_exit ->
    info CND.reverse " ^cli/browser@445-14^ process exiting; terminating browser process PID #{browser.pid} "
    browser.kill()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
run = ->
  parse_arguments()
  { server, port, } = await start_server()
  { browser, }      = await start_browser { server, port, }
  return null

#-----------------------------------------------------------------------------------------------------------
demo_websocket = ( port, pid ) =>
  url     = "ws://localhost:#{port}/terminals/#{pid}"
  WS      = require 'ws'
  ws      = new WS.WebSocket url
  ws.on 'open', () =>
    urge "^445-23^ websocket open"
    # ws.send 'echo "helo from server"'
  # ws.on 'message', ( data ) =>
  #   if cfg.echo
  #     process.stdout.write data # .toString()
  return null


############################################################################################################
do =>
  # GUY.process.on_exit ->
  #   info CND.reverse " ^409-7^ process exiting "
  await run()


