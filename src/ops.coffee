



'use strict'


_console = console


#===========================================================================================================
class Intercepted_console

  # #---------------------------------------------------------------------------------------------------------
  # constructor: ( target ) ->
  #   @target = target
  #   return undefined

  #---------------------------------------------------------------------------------------------------------
  get: ( target, key ) ->
    _console.log '^334-1^', key
    return target[ key ]
    # return Reflect.get arguments...

  #---------------------------------------------------------------------------------------------------------
  log: ( P... ) ->
    _console.log '^334-2^', P
    return _console.log P...

  # debug:            ƒ debug()
  # error:            ƒ error()
  # info:             ƒ info()
  # warn:             ƒ warn()

  #---------------------------------------------------------------------------------------------------------
  # assert:           ƒ assert()
  # clear:            ƒ clear()
  # context:          ƒ context()
  # count:            ƒ count()
  # countReset:       ƒ countReset()
  # dir:              ƒ dir()
  # dirxml:           ƒ dirxml()
  # group:            ƒ group()
  # groupCollapsed:   ƒ groupCollapsed()
  # groupEnd:         ƒ groupEnd()
  # memory:           MemoryInfo {totalJSHeapSize: 19300000, usedJSHeapSize: 19300000, jsHeapSizeLimit: 2190000000}
  # profile:          ƒ profile()
  # profileEnd:       ƒ profileEnd()
  # table:            ƒ table()
  # time:             ƒ time()
  # timeEnd:          ƒ timeEnd()
  # timeLog:          ƒ timeLog()
  # timeStamp:        ƒ timeStamp()
  # trace:            ƒ trace()

globalThis.console  = new Proxy console, new Intercepted_console()
globalThis.log      = console.log
globalThis.µ        = require 'mudom'
globalThis.DATOM    = require 'datom'
globalThis.GUY      = require 'guy'
globalThis.XE       = DATOM.new_xemitter()
globalThis.XXTERM   = {}

# globalThis.XXTERM   = {};
# { new_datom
#   new_xemitter
#   select }                = DATOM.export()


# XE = new_xemitter()
# XE.listen_to '^server/terminal/pid', ( { pid } ) -> log '^ops-late@7^', "PID: #{pid}"
# XE.emit '^server/terminal/pid', { pid: 1234, }
# console.log '^ops@4^', 'OK'
# log "^ops@5^ OPS loaded"
# console.log '^ops@6^', term
# console.log '^ops@7^', term.onKey

