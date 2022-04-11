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
const log             = console.log;

// Whether to use binary transport.
const USE_BINARY = os.platform() !== "win32";


/* ### NOTE: `XE` is a `datom/xemitter`` instance */
function startServer( XE ) {
  return new Promise( ( resolve, reject ) => {
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

    log('^server.js@734-1^ URL: ' + req.protocol + '://' + req.host + req.originalUrl);
    log('^server.js@734-1^ Created terminal with PID: ' + term.pid);
    XE.emit( '^server/terminal/pid', { pid: term.pid, } );
    terminals[term.pid] = term;
    logs[term.pid] = '';
    term.on('data', function(data) {
      logs[term.pid] += data;
    });
    res.send(term.pid.toString());
    res.end();
  });

  app.post('/terminals/:pid/size', (req, res) => {
    log('^server.js@734-1^ URL: ' + req.protocol + '://' + req.host + req.originalUrl);
    var pid = parseInt(req.params.pid),
        cols = parseInt(req.query.cols),
        rows = parseInt(req.query.rows),
        term = terminals[pid];

    term.resize(cols, rows);
    log('Resized terminal ' + pid + ' to ' + cols + ' cols and ' + rows + ' rows.');
    res.end();
  });

  app.ws('/terminals/:pid', function (ws, req) {
    var term = terminals[parseInt(req.params.pid)];
    log('Connected to terminal ' + term.pid);
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
      log('Closed terminal ' + term.pid);
      // Clean things up
      delete terminals[term.pid];
      delete logs[term.pid];
    });
  });
  // ### TAINT must validate host, port
  // const host = os.platform() === 'win32' ? '127.0.0.1' : '0.0.0.0';
  const host = process.env.xxterm_host || '127.0.0.1';
  const port = process.env.xxterm_port || 3000;
  log( CND.blue( '^server.js@734-1^', { host, port, } ) );

  app.on( 'error',            ( error ) => { log( CND.blue( '^server.js@734-8^', error ) ); } );
  process.stderr.on( 'data',  ( data  ) => { log( CND.blue( '^server.js@734-9^', data  ) ); } );

  //--------------------------------------------------------------------------------------------------------
  console.log('^server.js@734-2^ express app going to listen to http://' + host + ':' + port);
  const server = app.listen( { host, port, }, () => {
    console.log('^server.js@734-3^ express app listening to http://' + host + ':' + port);
    process.send?.( { $key: '^connect', port, } )
    resolve(); } );

  //--------------------------------------------------------------------------------------------------------
  server.on('error',function( error ) {
    // log( CND.red( CND.reverse( '^server.js@734-15^', error.code ) ) );
    log( CND.red( CND.reverse( '^server.js@734-16^', error.message ) ) );
    process.exit( 111 );
    throw error; } );
    } ); // Promise

}


module.exports = startServer;
