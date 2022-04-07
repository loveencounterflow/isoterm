



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
Combokeys           = require 'combokeys'
console.log '^3938^', 'OK'
log "^ops@1^ OPS loaded"

# modifier_names  = [  'Alt', 'AltGraph', 'Control', 'Meta', 'Shift', 'CapsLock', ]
# kms             = {} ### key modifier state ###
# count           = 0
# handler         = ( d ) ->
#   count++
#   e = {}
#   if ( mods = µ.KB.get_changed_kb_modifier_state() )?
#     kms = {}
#     for k, v of mods
#       continue if k is '_type'
#       continue if v is false
#       kms[ k ]  = v
#   e.keyname = d.keyname
#   e.state   = d.state if d.state
#   e[ k ]    = v for k, v of kms
#   log "^ops@3^", count, e
#   return null

#   # for k in modifier_names
#   #   delete kms[ k ] if kms[ k ] is false
#   # if mods?
#   # d   = { d..., }
#   # delete d.event
#   # delete d.state if d.state is false
#   # log "^ops@3^", count, { d..., kms..., }
#   # delete d._type
#   # delete d._type
#   # log "^ops@3^", count, { d..., kms..., }
# µ.KB._listen_to_key 'y', 'push', handler
# µ.KB._listen_to_key 'Y', 'push', handler
# µ.KB._listen_to_key '»', 'push', handler
# µ.KB._listen_to_key '›', 'push', handler
# # µ.KB._listen_to_modifiers         ( d ) -> log "^ops@3^", d

# µ.DOM.ready ->
count = 0
# µ.DOM.on document, 'keydown', ( event ) =>
#   count++
#   log "^ops@5^", count, event
ckeys   = new Combokeys document.documentElement
# target  = µ.DOM.select_first 'body'
# target  = µ.DOM.select_all '*'
# ckeys   = new Combokeys target
# log '^ops@45^', target
# bind    = ( keys, handler ) ->
#   ckeys.bind keys, handler, 'keydown'
ckeys.bind 'ctrl+y', ( event, key ) -> log '^ops@756^', event
ckeys.bind 'ctrl+k', ( event, key ) ->
  log '^ops@756^', "show or hide side bar"
  event.preventDefault()
  event.stopPropagation()
  return false
ckeys.bind 'ctrl+l', ( event, key ) ->
  log '^ops@756^', "activate address bar"
  event.preventDefault()
  event.stopPropagation()
  return false
return null


