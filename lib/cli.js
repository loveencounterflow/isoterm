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
    /* TAINT get or set port */
    var cp_cfg, port, server;
    process.chdir(xterm_path);
    cp_cfg = {
      detached: false
    };
    server = CP.fork(start_path, cp_cfg);
    server.on('error', (error) => {
      return warn('^server@445-2^', error);
    });
    server.on('close', () => {
      return whisper('^server@445-3^', 'close');
    });
    server.on('disconnect', () => {
      return whisper('^server@445-4^', 'disconnect');
    });
    server.on('error', () => {
      return whisper('^server@445-5^', 'error');
    });
    server.on('exit', () => {
      return whisper('^server@445-6^', 'exit');
    });
    server.on('message', () => {
      return whisper('^server@445-7^', 'message');
    });
    server.on('spawn', () => {
      return whisper('^server@445-8^', 'spawn');
    });
    help('^445-9^', 'Server started');
    port = 3000;
    return {server, port};
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
      return warn('^browser@445-10^', error);
    });
    browser.on('close', () => {
      return whisper('^browser@445-11^', 'close');
    });
    browser.on('disconnect', () => {
      return whisper('^browser@445-12^', 'disconnect');
    });
    browser.on('error', () => {
      return whisper('^browser@445-13^', 'error');
    });
    browser.on('exit', () => {
      whisper('^browser@445-14^', 'exit');
      return server.kill();
    });
    browser.on('message', () => {
      return whisper('^browser@445-15^', 'message');
    });
    browser.on('spawn', () => {
      return whisper('^browser@445-16^', 'spawn');
    });
    return {browser};
  };

  //-----------------------------------------------------------------------------------------------------------
  run = function() {
    var port, server;
    parse_arguments();
    ({server, port} = start_server());
    start_browser({server, port});
    info('^445-17^', {start_path, xterm_path});
    return null;
  };

  //###########################################################################################################
  run();

}).call(this);

//# sourceMappingURL=cli.js.map