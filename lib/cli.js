(function() {
  'use strict';
  var CND, CP, GUY, H, PATH, badge, debug, demo_websocket, echo, help, info, parse_arguments, port_pattern, rpr, run, start_browser, start_path, start_server, urge, warn, whisper, xterm_path;

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

  H = require('./helpers');

  port_pattern = /^33[0-9]{3}$/;

  // port_pattern              = /^8081$/
  GUY = require('guy');

  //-----------------------------------------------------------------------------------------------------------
  parse_arguments = function() {
    if (process.argv.length !== 2) {
      warn("^445-1^ this command doesn't accept parameters; terminating");
      return process.exit(1);
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  start_server = function() {
    return new Promise(async(resolve, reject) => {
      var conclude, cp_cfg, env, error, host, port, server, signals;
      port = null;
      host = '127.0.0.1';
      signals = {
        webpack: false,
        server: false,
        browser: false
      };
      //.........................................................................................................
      conclude = (signal) => {
        signals[signal] = true;
        if (signals.webpack && signals.server && (!signals.browser)) {
          signals.browser = true;
          return resolve({server, host, port});
        }
      };
      //.........................................................................................................
      process.chdir(xterm_path);
      port = (await H.find_free_port({
        port: port_pattern,
        fallback: null
      }));
      env = {
        ...process.env,
        xxterm_host: host,
        xxterm_port: port
      };
      cp_cfg = {
        detached: false,
        env
      };
      // cp_cfg            = { detached: false, }
      process.on('uncaughtException', (error) => {
        warn('^cli/server@445-2^', error);
        return process.exit(99);
      });
      try {
        server = CP.fork(start_path, cp_cfg);
      } catch (error1) {
        error = error1;
        warn('^445-3^', error);
      }
      // server.stderr.on 'data', ( data ) => warn '^445-4^', CND.reverse data
      // server.stdout.on 'data', ( data ) => info '^445-5^', CND.reverse data
      // debug '^5345^', server.stderr.toString().trim()
      //.........................................................................................................
      server.on('error', (error) => {
        return warn('^cli/server@445-6^', error);
      });
      //.........................................................................................................
      server.on('message', (d) => {
        var ref;
        // info '^cli/server@445-7^', d
        switch ((ref = d != null ? d.$key : void 0) != null ? ref : null) {
          case '^connect':
            help(`^cli/server@445-8^ serving on port ${rpr(d.port)}`);
            conclude('server');
            break;
          case '^webpack-ready':
            help("^cli/server@445-9^ webpack ready");
            conclude('webpack');
            break;
          case '^term-pid':
            help(`^cli/server@445-10^ received terminal PID ${d.pid}`);
            demo_websocket(host, port, d.pid);
            break;
          default:
            warn(`^cli/server@445-11^ unknown message format: ${rpr(d)}`);
        }
        return null;
      });
      //.........................................................................................................
      server.on('close', () => {
        return whisper('^cli/server@445-12^', 'close');
      });
      server.on('disconnect', () => {
        return whisper('^cli/server@445-13^', 'disconnect');
      });
      server.on('error', () => {
        return whisper('^cli/server@445-14^', 'error');
      });
      server.on('message', () => {
        return whisper('^cli/server@445-15^', 'message');
      });
      server.on('spawn', () => {
        return whisper('^cli/server@445-16^', 'spawn');
      });
      server.on('exit', () => {
        whisper('^cli/server@445-17^', 'exit');
        return process.exit(0);
      });
      //.........................................................................................................
      GUY.process.on_exit(function() {
        info(CND.reverse(` ^409-1^ process exiting; terminating server process PID ${server.pid} `));
        return server.kill();
      });
      //.........................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  start_browser = function(cfg) {
    return new Promise((resolve, reject) => {
      /* TAINT get address from `start_server()` */
      var address, browser, cmd, cp_cfg, defaults, host, parameters, port, server;
      defaults = {
        server: null,
        host: null,
        port: null
      };
      ({server, host, port} = {...defaults, ...cfg});
      cmd = 'chromium';
      address = `http://${host}:${port}`;
      parameters = [`--app=${address}`];
      cp_cfg = {
        detached: false
      };
      help('^cli/browser@445-18^', `spawning ${cmd} ${parameters.join(' ')}`);
      browser = CP.spawn(cmd, parameters, cp_cfg);
      browser.on('error', (error) => {
        return warn('^cli/browser@445-19^', error);
      });
      browser.on('close', () => {
        return whisper('^cli/browser@445-20^', 'close');
      });
      browser.on('disconnect', () => {
        return whisper('^cli/browser@445-21^', 'disconnect');
      });
      browser.on('error', () => {
        return whisper('^cli/browser@445-22^', 'error');
      });
      browser.on('message', () => {
        return whisper('^cli/browser@445-23^', 'message');
      });
      browser.on('spawn', () => {
        return whisper('^cli/browser@445-24^', 'spawn');
      });
      browser.on('exit', () => {
        whisper('^cli/browser@445-25^', 'exit');
        return process.exit(0);
      });
      //.........................................................................................................
      GUY.process.on_exit(function() {
        info(CND.reverse(` ^cli/browser@445-26^ process exiting; terminating browser process PID ${browser.pid} `));
        return browser.kill();
      });
      //.........................................................................................................
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  run = async function() {
    var browser, host, port, server;
    parse_arguments();
    ({server, host, port} = (await start_server()));
    ({browser} = (await start_browser({server, host, port})));
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  demo_websocket = (host, port, pid) => {
    var WS, url, ws;
    url = `ws://${host}:${port}/terminals/${pid}`;
    WS = require('ws');
    ws = new WS.WebSocket(url);
    ws.on('open', () => {
      return urge(`^cli/demo_websocket@445-27^ websocket open at ${url}`);
    });
    // ws.send 'echo "helo from server"'
    // ws.on 'message', ( data ) =>
    //   if cfg.echo
    //     process.stdout.write data # .toString()
    return null;
  };

  (async() => {    //###########################################################################################################
    // GUY.process.on_exit ->
    //   info CND.reverse " ^409-7^ process exiting "
    return (await run());
  })();

}).call(this);

//# sourceMappingURL=cli.js.map