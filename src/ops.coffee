



'use strict'


log = console.log
log '^554-1^', 'ops.js'

_console = console
handler =
  get: ( target, key ) =>
    _console.log '^334^', key
    target[ key ]

globalThis.console = new Proxy console, handler


