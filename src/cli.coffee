



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
H                         = require './helpers'
port_pattern              = /^33[0-9]{3}$/
# port_pattern              = /^8081$/
GUY                       = require 'guy'
_start_server             = require '../app/server.js'


#-----------------------------------------------------------------------------------------------------------
get_screen_dimensions = ->
  [ width, height, ] = ( require '@vamidicreations/screenres' ).get()
  return { width, height, }

#-----------------------------------------------------------------------------------------------------------
parse_arguments = ->
  if process.argv.length isnt 2
    warn "^445-1^ this command doesn't accept parameters; terminating"
    process.exit 1

#-----------------------------------------------------------------------------------------------------------
start_server = -> new Promise ( resolve, reject ) =>
  host                    = '127.0.0.1'
  port                    = await H.find_free_port { port: port_pattern, fallback: null, }
  process.env.xxterm_host = host
  process.env.xxterm_port = port
  process.chdir xterm_path
  ### TAINT use callback or events to communicate data such as `term.pid` from `server.js` ###
  await _start_server()
  #.........................................................................................................
  return resolve { server: process, host, port, }

#-----------------------------------------------------------------------------------------------------------
start_browser = ( cfg ) -> new Promise ( resolve, reject ) =>
  defaults    = { server: null, host: null, port: null, }
  { server
    host
    port }    = { defaults..., cfg..., }
  cmd         = 'chromium'
  ### TAINT get address from `start_server()` ###
  ### TAINT validate address not malformed ###
  address     = "http://#{host}:#{port}"
  screen      = get_screen_dimensions()
  # parameters  = [ "--window-position=0,0", "--window-size=#{screen.width},#{screen.height}", "--app=#{address}", ]
  parameters  = [ "--window-position=0,0", "--window-size=#{screen.width},#{screen.height}", "#{address}", "--auto-open-devtools-for-tabs", ]
  # parameters  = [ "--app=#{address}", ]
  cp_cfg      = { detached: false, }
  help '^cli/browser@445-18^', "spawning #{cmd} #{parameters.join ' '}"
  browser     = CP.spawn cmd, parameters, cp_cfg
  browser.on 'error', ( error ) => warn '^cli/browser@445-19^', error
  browser.on 'close',       => whisper '^cli/browser@445-20^', 'close'
  browser.on 'disconnect',  => whisper '^cli/browser@445-21^', 'disconnect'
  browser.on 'error',       => whisper '^cli/browser@445-22^', 'error'
  browser.on 'message',     => whisper '^cli/browser@445-23^', 'message'
  browser.on 'spawn',       =>
    whisper '^cli/browser@445-24^', 'spawn'
    demo_websocket host, port, browser.pid
    return null
  #.........................................................................................................
  browser.on 'exit', =>
    info CND.reverse " ^cli/browser@445-25^ browser exiting; terminating server process PID #{process.pid} "
    process.exit 0
  #.........................................................................................................
  GUY.process.on_exit ->
    info CND.reverse " ^cli/browser@445-26^ process exiting; terminating browser process PID #{browser.pid} "
    browser.kill()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
run = ->
  parse_arguments()
  { server, host, port, } = await start_server()
  { browser, }            = await start_browser { server, host, port, }
  return null

#-----------------------------------------------------------------------------------------------------------
demo_websocket = ( host, port, pid ) =>
  url     = "ws://#{host}:#{port}/terminals/#{pid}"
  WS      = require 'ws'
  ws      = new WS.WebSocket url
  urge "^cli/demo_websocket@445-27^ opening websocket at #{url}"
  urge "^cli/demo_websocket@445-27^ browser.pid #{pid}"
  urge "^cli/demo_websocket@445-27^ process.pid #{process.pid}"
  ws.on 'open', () =>
    urge "^cli/demo_websocket@445-27^ websocket open at #{url}"
    ws.send 'echo "helo from server"'
  ws.on 'message', ( data ) =>
    # if cfg.echo
    process.stdout.write data # .toString()
    return null
  return null


############################################################################################################
do =>
  # GUY.process.on_exit ->
  #   info CND.reverse " ^409-7^ process exiting "
  await run()

