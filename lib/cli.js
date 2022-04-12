(function() {
  'use strict';
  var CND, CP, DATOM, GUY, H, PATH, XE, _start_server, badge, debug, demo_websocket, echo, get_screen_dimensions, help, info, parse_arguments, port_pattern, rpr, run, start_browser, start_server, urge, warn, whisper, xterm_path;

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

  H = require('./helpers');

  port_pattern = /^33[0-9]{3}$/;

  // port_pattern              = /^8081$/
  GUY = require('guy');

  _start_server = require('../app/server.js');

  //...........................................................................................................
  DATOM = require('datom');

  // { new_datom
  //   new_xemitter
  //   select }                = DATOM.export()
  XE = DATOM.new_xemitter();

  XE.listen_to_all(function(key, d) {
    return debug('^cli/xemitter@445-27^', d);
  });

  XE.listen_to_unheard(function(key, d) {
    return debug('^cli/xemitter@445-27^', d);
  });

  //-----------------------------------------------------------------------------------------------------------
  get_screen_dimensions = function() {
    var height, width;
    [width, height] = (require('@vamidicreations/screenres')).get();
    return {width, height};
  };

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
      var host, port;
      host = '127.0.0.1';
      port = (await H.find_free_port({
        port: port_pattern,
        fallback: null
      }));
      process.env.xxterm_host = host;
      process.env.xxterm_port = port;
      process.chdir(xterm_path);
      /* TAINT use callback or events to communicate data such as `term.pid` from `server.js` */
      await _start_server(XE);
      XE.listen_to('^server/terminal/pid', function({pid}) {
        return demo_websocket(host, port, pid);
      });
      //.........................................................................................................
      return resolve({
        server: process,
        host,
        port
      });
    });
  };

  //-----------------------------------------------------------------------------------------------------------
  start_browser = function(cfg) {
    return new Promise((resolve, reject) => {
      /* TAINT get address from `start_server()` */
      /* TAINT validate address not malformed */
      var address, browser, cmd, cp_cfg, defaults, host, parameters, port, screen, server;
      defaults = {
        server: null,
        host: null,
        port: null
      };
      ({server, host, port} = {...defaults, ...cfg});
      cmd = 'chromium';
      address = `http://${host}:${port}`;
      screen = get_screen_dimensions();
      // parameters  = [ "--window-position=0,0", "--window-size=#{screen.width},#{screen.height}", "--app=#{address}", ]
      parameters = ["--window-position=0,0", `--window-size=${screen.width},${screen.height}`, `${address}`, "--auto-open-devtools-for-tabs"];
      // parameters  = [ "--app=#{address}", ]
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
        return whisper('^cli/browser@445-23^', 'spawn');
      });
      // browser.on 'spawn',       =>
      //   whisper '^cli/browser@445-24^', 'spawn'
      //   demo_websocket host, port, browser.pid
      //   return null
      //.........................................................................................................
      browser.on('exit', () => {
        info(CND.reverse(` ^cli/browser@445-25^ browser exiting; terminating server process PID ${process.pid} `));
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
    urge(`^cli/demo_websocket@445-27^ opening websocket at ${url}`);
    urge(`^cli/demo_websocket@445-27^ browser.pid ${pid}`);
    urge(`^cli/demo_websocket@445-27^ process.pid ${process.pid}`);
    ws.on('open', () => {
      urge(`^cli/demo_websocket@445-27^ websocket open at ${url}`);
      return ws.send('echo "helo from server"');
    });
    ws.on('message', (data) => {
      // if cfg.echo
      // process.stdout.write data # .toString()
      return null;
    });
    return null;
  };

  (async() => {    //###########################################################################################################
    // GUY.process.on_exit ->
    //   info CND.reverse " ^409-7^ process exiting "
    return (await run());
  })();

}).call(this);

//# sourceMappingURL=cli.js.map