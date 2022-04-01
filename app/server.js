/**
 * WARNING: This demo is a barebones implementation designed for development and evaluation
 * purposes only. It is definitely NOT production ready and does not aim to be so. Exposing the
 * demo to the public as is would introduce security risks for the host.
 **/

const CND             = require( 'cnd' );
const GUY             = require( 'guy' );
/* ### TAINT use helper module with `require_from_xterm()` method */
const PATH            = require('path');
const xterm_path      = PATH.resolve( PATH.join( __dirname, '../xterm' ) );
// const express_path    = require.resolve( 'express', { paths: [ xterm_path, ], } );
const expressWs_path  = require.resolve( 'express-ws', { paths: [ xterm_path, ], } );
const pty_path        = require.resolve( 'node-pty', { paths: [ xterm_path, ], } );
// var express           = require( express_path );
const express         = require( 'express' );
var expressWs         = require( expressWs_path );
var os                = require('os');
var pty               = require( pty_path );

// Whether to use binary transport.
const USE_BINARY = os.platform() !== "win32";

function startServer() {
  var app = express();
  expressWs(app);

  var terminals = {},
      logs = {};

  app.use('/xterm.css', express.static( __dirname + '/xterm.css' ) );
  app.get('/logo.png', (req, res) => { // lgtm [js/missing-rate-limiting]
    res.sendFile(__dirname + '/logo.png');
  });

  app.get('/', (req, res) => { // lgtm [js/missing-rate-limiting]
    res.sendFile(__dirname + '/index.html');
  });

  app.get('/test', (req, res) => { // lgtm [js/missing-rate-limiting]
    res.sendFile(__dirname + '/test.html');
  });

  app.get('/style.css', (req, res) => { // lgtm [js/missing-rate-limiting]
    res.sendFile(__dirname + '/style.css');
  });

  app.use('/static', express.static(__dirname + '/static'));
  app.use('/fonts', express.static(__dirname + '/fonts'));
  app.use('/dist', express.static(__dirname + '/dist'));
  app.use('/src', express.static(__dirname + '/src'));

  app.post('/terminals', (req, res) => {
    const env = Object.assign({}, process.env);
    env['COLORTERM'] = 'truecolor';
    var cols = parseInt(req.query.cols),
      rows = parseInt(req.query.rows),
      term = pty.spawn(process.platform === 'win32' ? 'cmd.exe' : 'zsh', [], {
      // term = pty.spawn(process.platform === 'win32' ? 'cmd.exe' : 'bash', [], {
        name: 'xterm-256color',
        cols: cols || 80,
        rows: rows || 24,
        cwd: process.platform === 'win32' ? undefined : env.PWD,
        env: env,
        encoding: USE_BINARY ? null : 'utf8'
      });

    console.log('Created terminal with PID: ' + term.pid);
    process.send?.( { $key: '^term-pid', pid: term.pid, } );
    terminals[term.pid] = term;
    logs[term.pid] = '';
    term.on('data', function(data) {
      logs[term.pid] += data;
    });
    res.send(term.pid.toString());
    res.end();
  });

  app.post('/terminals/:pid/size', (req, res) => {
    var pid = parseInt(req.params.pid),
        cols = parseInt(req.query.cols),
        rows = parseInt(req.query.rows),
        term = terminals[pid];

    term.resize(cols, rows);
    console.log('Resized terminal ' + pid + ' to ' + cols + ' cols and ' + rows + ' rows.');
    res.end();
  });

  app.ws('/terminals/:pid', function (ws, req) {
    var term = terminals[parseInt(req.params.pid)];
    console.log('Connected to terminal ' + term.pid);
    ws.send(logs[term.pid]);

    // string message buffering
    function buffer(socket, timeout) {
      let s = '';
      let sender = null;
      return (data) => {
        s += data;
        if (!sender) {
          sender = setTimeout(() => {
            socket.send(s);
            s = '';
            sender = null;
          }, timeout);
        }
      };
    }
    // binary message buffering
    function bufferUtf8(socket, timeout) {
      let buffer = [];
      let sender = null;
      let length = 0;
      return (data) => {
        buffer.push(data);
        length += data.length;
        if (!sender) {
          sender = setTimeout(() => {
            socket.send(Buffer.concat(buffer, length));
            buffer = [];
            sender = null;
            length = 0;
          }, timeout);
        }
      };
    }
    const send = USE_BINARY ? bufferUtf8(ws, 5) : buffer(ws, 5);

    term.on('data', function(data) {
      try {
        send(data);
      } catch (ex) {
        // The WebSocket is not open, ignore
      }
    });
    ws.on('message', function(msg) {
      term.write(msg);
    });
    ws.on('close', function () {
      term.kill();
      console.log('Closed terminal ' + term.pid);
      // Clean things up
      delete terminals[term.pid];
      delete logs[term.pid];
    });
  });
  // ### TAINT must validate port is legal number
  var port = process.env.xxterm_port || 3000,
      host = os.platform() === 'win32' ? '127.0.0.1' : '0.0.0.0';

  GUY.process.on_exit( () => {
    console.log( CND.blue( '^server.js@734-1^' ) );
  } );
  process.on( 'uncaughtException', ( error ) => {
     CND.red( '^server.js@734-2^', error );
     process.exit( 123 ); })
  process.on( 'unhandledRejection', ( error ) => {
     CND.red( '^server.js@734-3^', error );
     process.exit( 123 ); })
  process.on('uncaughtExceptionMonitor', (error, origin) => {
     CND.red( '^server.js@734-4^', error );
     CND.red( '^server.js@734-5^', origin );
     process.exit( 123 ); })
  process.on('unhandledRejection', (reason, promise) => {
    console.log( CND.red( '^server.js@734-6^', 'Unhandled Rejection at:', promise, 'reason:', reason ) ); } );

  app.on( 'error',            ( error ) => { console.log( CND.blue( '^server.js@734-7^', error ) ); } );
  process.stderr.on( 'data',  ( data  ) => { console.log( CND.blue( '^server.js@734-8^', data  ) ); } );
  var server = null;
  try {
    // -----------------------------------------------------------------------------------------------------
    // server = app.listen( port, host, ( error ) => {
    //   console.log( CND.red( '^server.js@734-9^', error ) );
    //   console.log( CND.red( '^server.js@734-10^ express app listening to http://127.0.0.1:' + port ) );
    //   process.send( { $key: '^connect', port, } ) } );
    // server.on('error',function( error ) {
    //   console.log( CND.red( '^server.js@734-11^', error.code ) );
    //   if ( error != null ) { throw error; } } );
    // -----------------------------------------------------------------------------------------------------
    const HTTP = require( 'http' );
    server  = HTTP.createServer(app);
    server.listen( port, host, ( error ) => {
      console.log( CND.red( '^server.js@734-12^', error ) );
      console.log( CND.red( '^server.js@734-13^ express app listening to http://127.0.0.1:' + port ) );
      process.send( { $key: '^connect', port, } ) } );
    server.on('error',function( error ) {
      console.log( CND.red( '^server.js@734-14^', error.code ) );
      if ( error != null ) { throw error; } } );
    // -----------------------------------------------------------------------------------------------------
  }

  catch ( error ) {
    console.log( CND.red( '^server.js@734-15^', error ) );
    };
  // console.log( CND.yellow( '^server.js@734-16^', server ) );
  console.log( CND.lime( '^server.js@734-17^', server === app ) );
  server.on( 'error',            ( error ) => { console.log( CND.blue( '^server.js@734-18^', error ) ); } );

}

module.exports = startServer;
