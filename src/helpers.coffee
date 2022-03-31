



'use strict'



############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'XXTERM/HELPERS'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
types                     = new ( require 'intertype' ).Intertype()
{ isa
  type_of
  validate
  validate_list_of }      = types.export()
# GUY                       = require 'guy'
# { lets
#   freeze
#   thaw }                  = GUY.lft
{ check: post_is_used, }                        = require 'port-used'
Randex                    = require 'randexp'
misfit                    = Symbol 'misfit'


#===========================================================================================================
types.declare 'find_free_port_cfg', tests:
  "@isa.object x":                    ( x ) -> @isa.object x
  "( @isa.regex x.port )":            ( x ) -> ( @isa.regex x.port )
  "( @isa.cardinal x.tries )":        ( x ) -> ( @isa.cardinal x.tries )
  "( @isa.boolean x.verbose )":       ( x ) -> ( @isa.boolean x.verbose )
  # "( @isa.any x.fallback )":          ( x ) -> ( @isa.any x.fallback )

#-----------------------------------------------------------------------------------------------------------
defaults =
  find_free_port_cfg:
    # port:             /^[1-9]111$/
    # port:             /^5[0-9]{2}11$/
    port:             /^([1-9][0-9]{3}|[1-5][0-9]{3}|6[0-5][0-9]{2})$/
    tries:            100
    fallback:         misfit
    verbose:          false

#-----------------------------------------------------------------------------------------------------------
@find_free_port = ( cfg ) =>
  ### Find free port for the connection between the server and the web terminal. Can give `pattern`, will
  generate strings to match. Results must be digits-only and be a valid port number between 1024 and 65535
  (inclusively). ###
  cfg     = { defaults.find_free_port_cfg..., cfg..., }
  validate.find_free_port_cfg cfg
  count   = 0
  randex  = new Randex cfg.port
  for _ in [ 1 .. cfg.tries ] by +1
    port = randex.gen()
    unless /^[0-9]+$/.test port
      throw new Error "^xxterm/find_free_port@1^ the supplied pattern resulted in an illegal port number: #{rpr port}"
    port = parseInt port, 10
    unless 1024 <= port <= 65535
      whisper "^xxterm/find_free_port@2^ port number not in range: #{rpr port}" if cfg.verbose
      continue
    count++
    whisper "^xxterm/find_free_port@2^ checking whether port #{rpr port} is free" if cfg.verbose
    # debug '^332^', post_is_used port
    return port if not await post_is_used port
  return cfg.fallback unless cfg.fallback is misfit
  throw new Error "^xxterm/find_free_port@3^ unable to find port with #{rpr cfg}, tried #{count} times"


############################################################################################################
if module is require.main then do =>
  # await run()
  urge '^345^', await @find_free_port { verbose: true, fallback: null, }







