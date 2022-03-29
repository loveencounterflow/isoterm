(function() {
  'use strict';
  var CND, CP, PATH, badge, debug, echo, help, info, parse_arguments, rpr, run, start_browser, start_path, start_server, urge, warn, whisper, xterm_path;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'XTERM';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  info = CND.get_logger('info', badge);

  urge = CND.get_logger('urge', badge);

  help = CND.get_logger('help', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  //...........................................................................................................
  PATH = require('path');

  CP = require('child_process');

  //...........................................................................................................
  xterm_path = PATH.resolve(PATH.join(__dirname, '../xterm'));

  start_path = PATH.resolve(PATH.join(__dirname, '../app/start.js'));

  //-----------------------------------------------------------------------------------------------------------
  parse_arguments = function() {
    if (process.argv.length !== 2) {
      warn("^445-1^ this command doesn't accept parameters; terminating");
      return process.exit(1);
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  start_server = function() {
    return new Promise((resolve, reject) => {
      var cp_cfg, server;
      process.chdir(xterm_path);
      cp_cfg = {
        detached: false
      };
      server = CP.fork(start_path, cp_cfg);
      server.on('error', (error) => {
        return warn('^server@445-2^', error);
      });
      server.on('message', (message) => {
        var port, ref;
        // info '^server@445-3^', message
        switch ((ref = message != null ? message.$key : void 0) != null ? ref : null) {
          case '^connect':
            ({port} = message);
            help(`^server@445-4^ serving on port ${rpr(port)}`);
            resolve({server, port});
            break;
          default:
            warn(`^server@445-5^ unknown message format: ${rpr(message)}`);
        }
        return null;
      });
      server.on('close', () => {
        return whisper('^server@445-6^', 'close');
      });
      server.on('disconnect', () => {
        return whisper('^server@445-7^', 'disconnect');
      });
      server.on('error', () => {
        return whisper('^server@445-8^', 'error');
      });
      server.on('exit', () => {
        return whisper('^server@445-9^', 'exit');
      });
      server.on('message', () => {
        return whisper('^server@445-10^', 'message');
      });
      server.on('spawn', () => {
        return whisper('^server@445-11^', 'spawn');
      });
      // help '^445-12^', 'Server started'
      // debug '^445-13^', server.channel
      /* TAINT get or set port */
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  start_browser = function(cfg) {
    /* TAINT get address from `start_server()` */
    var address, browser, cmd, cp_cfg, defaults, parameters, port, server;
    defaults = {
      port: null
    };
    ({server, port} = {...defaults, ...cfg});
    cmd = 'chromium';
    address = `http://localhost:${port}`;
    parameters = [`--app=${address}`];
    cp_cfg = {
      detached: false
    };
    browser = CP.spawn(cmd, parameters, cp_cfg);
    browser.on('error', (error) => {
      return warn('^browser@445-14^', error);
    });
    browser.on('close', () => {
      return whisper('^browser@445-15^', 'close');
    });
    browser.on('disconnect', () => {
      return whisper('^browser@445-16^', 'disconnect');
    });
    browser.on('error', () => {
      return whisper('^browser@445-17^', 'error');
    });
    browser.on('exit', () => {
      whisper('^browser@445-18^', 'exit');
      return server.kill();
    });
    browser.on('message', () => {
      return whisper('^browser@445-19^', 'message');
    });
    browser.on('spawn', () => {
      return whisper('^browser@445-20^', 'spawn');
    });
    return {browser};
  };

  //-----------------------------------------------------------------------------------------------------------
  run = async function() {
    var port, server;
    parse_arguments();
    ({server, port} = (await start_server()));
    start_browser({server, port});
    info('^445-21^', {start_path, xterm_path});
    return null;
  };

  (async() => {    //###########################################################################################################
    return (await run());
  })();

}).call(this);

//# sourceMappingURL=cli.js.map