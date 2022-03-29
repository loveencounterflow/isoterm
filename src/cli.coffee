



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
  process.chdir xterm_path
  cp_cfg  = { detached: false, }
  server  = CP.fork start_path, cp_cfg
  server.on 'error', ( error ) => warn '^server@445-2^', error
  server.on 'message', ( message ) =>
    # info '^server@445-3^', message
    switch message?.$key ? null
      when '^connect'
        { port } = message
        help "^server@445-4^ serving on port #{rpr port}"
        resolve { server, port, }
      else
        warn "^server@445-5^ unknown message format: #{rpr message}"
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
  start_browser { server, port, }
  info '^445-21^', { start_path, xterm_path }
  return null


############################################################################################################
do =>
  await run()







