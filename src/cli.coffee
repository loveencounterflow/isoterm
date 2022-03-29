



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
start_server = ->
  process.chdir xterm_path
  cp_cfg  = { detached: false, }
  server  = CP.fork start_path, cp_cfg
  server.on 'error', ( error ) => warn '^server@445-2^', error
  server.on 'close',      => whisper '^server@445-3^', 'close'
  server.on 'disconnect', => whisper '^server@445-4^', 'disconnect'
  server.on 'error',      => whisper '^server@445-5^', 'error'
  server.on 'exit',       => whisper '^server@445-6^', 'exit'
  server.on 'message',    => whisper '^server@445-7^', 'message'
  server.on 'spawn',      => whisper '^server@445-8^', 'spawn'
  help '^445-9^', 'Server started'
  ### TAINT get or set port ###
  port = 3000
  return { server, port, }

#-----------------------------------------------------------------------------------------------------------
start_browser = ( cfg ) ->
  defaults    = { port: null, }
  { server
    port }    = { defaults..., cfg..., }
  cmd         = 'chromium'
  ### TAINT get address from `start_server()` ###
  address     = "http://localhost:#{port}"
  parameters  = [ "--app=#{address}", ]
  cp_cfg      = { detached: false, }
  browser     = CP.spawn cmd, parameters, cp_cfg
  browser.on 'error', ( error ) => warn '^browser@445-10^', error
  browser.on 'close',      => whisper '^browser@445-11^', 'close'
  browser.on 'disconnect', => whisper '^browser@445-12^', 'disconnect'
  browser.on 'error',      => whisper '^browser@445-13^', 'error'
  browser.on 'exit',       => whisper '^browser@445-14^', 'exit'; server.kill()
  browser.on 'message',    => whisper '^browser@445-15^', 'message'
  browser.on 'spawn',      => whisper '^browser@445-16^', 'spawn'
  return { browser, }

#-----------------------------------------------------------------------------------------------------------
run = ->
  parse_arguments()
  { server, port, } = start_server()
  start_browser { server, port, }
  info '^445-17^', { start_path, xterm_path }
  return null

############################################################################################################
run()







