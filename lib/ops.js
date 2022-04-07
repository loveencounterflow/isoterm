(function() {
  'use strict';
  var Combokeys, Intercepted_console, _console, count;

  _console = console;

  //===========================================================================================================
  Intercepted_console = class Intercepted_console {
    // #---------------------------------------------------------------------------------------------------------
    // constructor: ( target ) ->
    //   @target = target
    //   return undefined

      //---------------------------------------------------------------------------------------------------------
    get(target, key) {
      _console.log('^334-1^', key);
      return target[key];
    }

    // return Reflect.get arguments...

      //---------------------------------------------------------------------------------------------------------
    log(...P) {
      _console.log('^334-2^', P);
      return _console.log(...P);
    }

  };

  // debug:            ƒ debug()
  // error:            ƒ error()
  // info:             ƒ info()
  // warn:             ƒ warn()

  //---------------------------------------------------------------------------------------------------------
  // assert:           ƒ assert()
  // clear:            ƒ clear()
  // context:          ƒ context()
  // count:            ƒ count()
  // countReset:       ƒ countReset()
  // dir:              ƒ dir()
  // dirxml:           ƒ dirxml()
  // group:            ƒ group()
  // groupCollapsed:   ƒ groupCollapsed()
  // groupEnd:         ƒ groupEnd()
  // memory:           MemoryInfo {totalJSHeapSize: 19300000, usedJSHeapSize: 19300000, jsHeapSizeLimit: 2190000000}
  // profile:          ƒ profile()
  // profileEnd:       ƒ profileEnd()
  // table:            ƒ table()
  // time:             ƒ time()
  // timeEnd:          ƒ timeEnd()
  // timeLog:          ƒ timeLog()
  // timeStamp:        ƒ timeStamp()
  // trace:            ƒ trace()
  globalThis.console = new Proxy(console, new Intercepted_console());

  globalThis.log = console.log;

  globalThis.µ = require('mudom');

  // globalThis.XXTERM   = {};
  Combokeys = require('combokeys');

  count = 0;

  // ckeys               = new Combokeys document.documentElement
  // ckeys               = new Combokeys µ.DOM.select_id 'terminal-container'
  // ckeys.bind 'ctrl+y', ( event, key ) -> log '^ops@756^', event
  // ckeys.bind 'ctrl+k', ( event, key ) ->
  //   log '^ops@756^', "show or hide side bar"
  //   event.preventDefault()
  //   event.stopPropagation()
  //   return false
  // ckeys.bind 'ctrl+l', ( event, key ) ->
  //   log '^ops@756^', "activate address bar"
  //   event.preventDefault()
  //   event.stopPropagation()
  //   return false
  console.log('^3938^', 'OK');

  log("^ops@1^ OPS loaded");

}).call(this);

//# sourceMappingURL=ops.js.map