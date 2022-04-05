/**
 * Copyright (c) 2018 The xterm.js authors. All rights reserved.
 * @license MIT
 *
 * This file is the entry point for browserify.
 */


/* ### TAINT use helper module with `require_from_xterm()` method */
const PATH          = require('path');
const startServer   = require('./server.js');

startServer();

