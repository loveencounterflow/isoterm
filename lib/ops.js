(function() {
  'use strict';
  var _console, handler, log;

  log = console.log;

  log('^554-1^', 'ops.js');

  _console = console;

  handler = {
    get: (target, key) => {
      _console.log('^334^', key);
      return target[key];
    }
  };

  globalThis.console = new Proxy(console, handler);

}).call(this);

//# sourceMappingURL=ops.js.map