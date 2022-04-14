



'use strict'



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'XXTERM/CLI'
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
# _start_server             = require '../app/server.js'
_start_server             = require './server2.js'
#...........................................................................................................
DATOM                     = require 'datom'
# { new_datom
#   new_xemitter
#   select }                = DATOM.export()
XE                        = DATOM.new_xemitter()
MIXA                      = require 'mixa'


#-----------------------------------------------------------------------------------------------------------
get_screen_dimensions = ->
  [ width, height, ] = ( require '@vamidicreations/screenres' ).get()
  return { width, height, }

#-----------------------------------------------------------------------------------------------------------
start_server = -> new Promise ( resolve, reject ) =>
  host                    = '127.0.0.1'
  port                    = await H.find_free_port { port: port_pattern, fallback: null, }
  process.env.xxterm_host = host
  process.env.xxterm_port = port
  process.chdir xterm_path
  ### TAINT use callback or events to communicate data such as `term.pid` from `server.js` ###
  await _start_server XE
  XE.listen_to '^server/terminal/pid', ( { pid } ) -> demo_websocket host, port, pid
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
  help '^cli/browser@4^', "spawning #{cmd} #{parameters.join ' '}"
  browser     = CP.spawn cmd, parameters, cp_cfg
  browser.on 'error', ( error ) => warn '^cli/browser@5^', error
  browser.on 'close',       => whisper '^cli/browser@6^', 'close'
  browser.on 'disconnect',  => whisper '^cli/browser@7^', 'disconnect'
  browser.on 'error',       => whisper '^cli/browser@8^', 'error'
  browser.on 'message',     => whisper '^cli/browser@9^', 'message'
  browser.on 'spawn',       => whisper '^cli/browser@10^', 'spawn'
  # browser.on 'spawn',       =>
  #   whisper '^cli/browser@11^', 'spawn'
  #   demo_websocket host, port, browser.pid
  #   return null
  #.........................................................................................................
  browser.on 'exit', =>
    info CND.reverse " ^cli/browser@12^ browser exiting; terminating server process PID #{process.pid} "
    process.exit 0
  #.........................................................................................................
  GUY.process.on_exit ->
    info CND.reverse " ^cli/browser@13^ process exiting; terminating browser process PID #{browser.pid} "
    browser.kill()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
start_server_and_browser = ->
  { server, host, port, } = await start_server()
  { browser, }            = await start_browser { server, host, port, }
  return { server, host, port, browser, }

#-----------------------------------------------------------------------------------------------------------
### TAINT consider to utilize XE messages from `server.js` instead of opening own WS instance ###
demo_websocket = ( host, port, pid ) =>
  url     = "ws://#{host}:#{port}/terminals/#{pid}"
  WS      = require 'ws'
  ws      = new WS.WebSocket url
  urge "^cli/demo_websocket@14^ opening websocket at #{url}"
  urge "^cli/demo_websocket@15^ browser.pid #{pid}"
  urge "^cli/demo_websocket@16^ process.pid #{process.pid}"
  ws.on 'open', () =>
    urge "^cli/demo_websocket@17^ websocket open at #{url}"
    ws.send 'echo "helo from server"'
  ws.on 'message', ( data ) =>
    # if cfg.echo
    # process.stdout.write data # .toString()
    XE.emit '^cli/browser/terminal/data', { data, }
    return null
  return null


#===========================================================================================================
# XE event handlers
#-----------------------------------------------------------------------------------------------------------
# XE.listen_to_all      ( key, d  ) -> debug '^cli/xemitter@2^', d
XE.listen_to_unheard  ( key, d  ) -> whisper '^cli/xemitter@3^', d

#-----------------------------------------------------------------------------------------------------------
XE.listen_to '^cli/browser/terminal/data', ( { data, } ) ->
  # whisper '^cli@18^', "received #{data.length} bytes"
  # process.stdout.write data

#-----------------------------------------------------------------------------------------------------------
XE.listen_to '^server/ws/data', ( { data, } ) ->
  # whisper '^cli@18a^', "received #{data.length} bytes"
  # process.stdout.write data



#===========================================================================================================
# CLI
#-----------------------------------------------------------------------------------------------------------
cli = -> new Promise ( done ) =>
  #.........................................................................................................
  jobdefs =
    default_command: 'start'
    commands:
      #-----------------------------------------------------------------------------------------------------
      'start':
        description:  "start browser with terminal"
        runner: ( d ) =>
          await start_server_and_browser()
          done()
      # #-----------------------------------------------------------------------------------------------------
      # 'copy-data':
      #   description:  "copy data into DB; specify individual DSKs or 'all'"
      #   flags:
      #     'input':
      #       alias:        'i'
      #       type:         String
      #       positional:   true
      #       multiple:     'greedy'
      #       description:  "input file(s)"
      #   runner: ( d ) =>
      #     unless ( dsks = d.verdict.parameters.input )?
      #       warn "need at least one DSK; use 'all' to copy data from all files"
      #     debug '^33344^', { dsks, }
      #     await copy_data dsks
      #     done()
  #.........................................................................................................
  MIXA.run jobdefs, process.argv
  return null


############################################################################################################
do =>
  # GUY.process.on_exit ->
  #   info CND.reverse " ^409-7^ process exiting "
  await cli()


