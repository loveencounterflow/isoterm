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

  // port_pattern              = /^33[0-9]{3}$/
  port_pattern = /^33333$/;

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
      var PORT, conclude, cp_cfg, env, port, server, signals;
      port = null;
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
          return resolve({server, port});
        }
      };
      //.........................................................................................................
      process.chdir(xterm_path);
      PORT = (await H.find_free_port({
        port: port_pattern
      }));
      env = {...process.env, PORT};
      cp_cfg = {
        detached: false,
        env
      };
      // cp_cfg            = { detached: false, }
      server = CP.fork(start_path, cp_cfg);
      //.........................................................................................................
      server.on('error', (error) => {
        return warn('^server@445-2^', error);
      });
      //.........................................................................................................
      server.on('message', (d) => {
        var ref;
        // info '^server@445-3^', d
        switch ((ref = d != null ? d.$key : void 0) != null ? ref : null) {
          case '^connect':
            port = d.port;
            help(`^server@445-4^ serving on port ${rpr(port)}`);
            conclude('server');
            break;
          case '^webpack-ready':
            help("^server@445-5^ webpack ready");
            conclude('webpack');
            break;
          case '^term-pid':
            help(`^server@445-5^ received terminal PID ${d.pid}`);
            demo_websocket(d.pid);
            break;
          default:
            warn(`^server@445-6^ unknown message format: ${rpr(d)}`);
        }
        return null;
      });
      //.........................................................................................................
      server.on('close', () => {
        return whisper('^server@445-7^', 'close');
      });
      server.on('disconnect', () => {
        return whisper('^server@445-8^', 'disconnect');
      });
      server.on('error', () => {
        return whisper('^server@445-9^', 'error');
      });
      server.on('exit', () => {
        return whisper('^server@445-10^', 'exit');
      });
      server.on('message', () => {
        return whisper('^server@445-11^', 'message');
      });
      server.on('spawn', () => {
        return whisper('^server@445-12^', 'spawn');
      });
      //.........................................................................................................
      GUY.process.on_exit(async function() {
        info(CND.reverse(" ^409-1^ process exiting "));
        help('^409-2^', `terminating process PID ${server.pid}`);
        await server.kill();
        return help('^409-3^', `server exited: ${server.killed}`);
      });
      // help '^445-13^', 'Server started'
      // debug '^445-14^', server.channel
      /* TAINT get or set port */
      return null;
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  start_browser = function(cfg) {
    return new Promise((resolve, reject) => {
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
        return warn('^browser@445-15^', error);
      });
      browser.on('close', () => {
        return whisper('^browser@445-16^', 'close');
      });
      browser.on('disconnect', () => {
        return whisper('^browser@445-17^', 'disconnect');
      });
      browser.on('error', () => {
        return whisper('^browser@445-18^', 'error');
      });
      browser.on('exit', () => {
        return whisper('^browser@445-19^', 'exit');
      });
      browser.on('message', () => {
        return whisper('^browser@445-20^', 'message');
      });
      browser.on('spawn', () => {
        return whisper('^browser@445-21^', 'spawn');
      });
      //.........................................................................................................
      GUY.process.on_exit(async function() {
        info(CND.reverse(" ^409-4^ process exiting "));
        help('^409-5^', `terminating process PID ${browser.pid}`);
        await browser.kill('SIGKILL');
        return help('^409-6^', `browser exited: ${browser.killed}`);
      });
      return {browser};
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  run = async function() {
    var browser, port, server;
    parse_arguments();
    ({server, port} = (await start_server()));
    ({browser} = (await start_browser({server, port})));
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  demo_websocket = (pid) => {
    var WS, url, ws;
    url = `ws://localhost:3000/terminals/${pid}`;
    WS = require('ws');
    ws = new WS.WebSocket(url);
    ws.on('open', () => {
      return urge("^445-23^ websocket open");
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