(function() {
  'use strict';
  var CND, Randex, badge, debug, defaults, echo, help, info, isa, misfit, post_is_used, rpr, type_of, types, urge, validate, validate_list_of, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'ISOTERM/HELPERS';

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  info = CND.get_logger('info', badge);

  urge = CND.get_logger('urge', badge);

  help = CND.get_logger('help', badge);

  whisper = CND.get_logger('whisper', badge);

  echo = CND.echo.bind(CND);

  types = new (require('intertype')).Intertype();

  ({isa, type_of, validate, validate_list_of} = types.export());

  ({
    // GUY                       = require 'guy'
    // { lets
    //   freeze
    //   thaw }                  = GUY.lft
    check: post_is_used
  } = require('port-used'));

  Randex = require('randexp');

  misfit = Symbol('misfit');

  //===========================================================================================================
  types.declare('find_free_port_cfg', {
    tests: {
      "@isa.object x": function(x) {
        return this.isa.object(x);
      },
      "( @isa.regex x.port )": function(x) {
        return this.isa.regex(x.port);
      },
      "( @isa.cardinal x.tries )": function(x) {
        return this.isa.cardinal(x.tries);
      },
      "( @isa.boolean x.verbose )": function(x) {
        return this.isa.boolean(x.verbose);
      }
    }
  });

  // "( @isa.any x.fallback )":          ( x ) -> ( @isa.any x.fallback )

  //-----------------------------------------------------------------------------------------------------------
  defaults = {
    find_free_port_cfg: {
      // port:             /^[1-9]111$/
      // port:             /^5[0-9]{2}11$/
      port: /^([1-9][0-9]{3}|[1-5][0-9]{3}|6[0-5][0-9]{2})$/,
      tries: 100,
      fallback: misfit,
      verbose: false
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  this.find_free_port = async(cfg) => {
    var _, count, i, port, randex, ref;
    cfg = {...defaults.find_free_port_cfg, ...cfg};
    validate.find_free_port_cfg(cfg);
    count = 0;
    randex = new Randex(cfg.port);
    for (_ = i = 1, ref = cfg.tries; i <= ref; _ = i += +1) {
      port = randex.gen();
      if (!/^[0-9]+$/.test(port)) {
        throw new Error(`^isoterm/find_free_port@1^ the supplied pattern resulted in an illegal port number: ${rpr(port)}`);
      }
      port = parseInt(port, 10);
      if (!((1024 <= port && port <= 65535))) {
        if (cfg.verbose) {
          whisper(`^isoterm/find_free_port@2^ port number not in range: ${rpr(port)}`);
        }
        continue;
      }
      count++;
      if (cfg.verbose) {
        whisper(`^isoterm/find_free_port@2^ checking whether port ${rpr(port)} is free`);
      }
      if (!(await post_is_used(port))) {
        // debug '^332^', post_is_used port
        return port;
      }
    }
    if (cfg.fallback !== misfit) {
      return cfg.fallback;
    }
    throw new Error(`^isoterm/find_free_port@3^ unable to find port with ${rpr(cfg)}, tried ${count} times`);
  };

  //###########################################################################################################
  if (module === require.main) {
    (async() => {
      // await run()
      return urge('^345^', (await this.find_free_port({
        verbose: true,
        fallback: null
      })));
    })();
  }

}).call(this);

//# sourceMappingURL=helpers.js.map