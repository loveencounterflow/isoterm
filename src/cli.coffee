



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
# port_pattern              = /^33[0-9]{3}$/
port_pattern              = /^33333$/
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
  port              = await H.find_free_port { port: port_pattern, }
  env               = { process.env..., xxterm_port: port, }
  cp_cfg            = { detached: false, env, }
  # cp_cfg            = { detached: false, }
  server            = CP.fork start_path, cp_cfg
  #.........................................................................................................
  server.on 'error', ( error ) => warn '^server@445-2^', error
  #.........................................................................................................
  server.on 'message', ( d ) =>
    # info '^server@445-3^', d
    switch d?.$key ? null
      when '^connect'
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
  #.........................................................................................................
  GUY.process.on_exit ->
    info CND.reverse " ^409-1^ process exiting "
    help '^409-2^', "terminating process PID #{server.pid}"
    server.kill()
    help '^409-3^', "server exited: #{server.killed}"
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
  browser.on 'exit',       => whisper '^browser@445-19^', 'exit'
  browser.on 'message',    => whisper '^browser@445-20^', 'message'
  browser.on 'spawn',      => whisper '^browser@445-21^', 'spawn'
  #.........................................................................................................
  GUY.process.on_exit ->
    info CND.reverse " ^409-4^ process exiting "
    help '^409-5^', "terminating process PID #{browser.pid}"
    browser.kill 'SIGKILL'
    help '^409-6^', "browser exited: #{browser.killed}"
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


