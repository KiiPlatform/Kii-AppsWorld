var fs = require('fs'),
    util = require('util'),
    url = require('url'),
    http = require('./kiiHttp');

var hosts = {
  'us': 'api.kii.com',
  'jp': 'api-jp.kii.com',
  'cn': 'api-cn2.kii.com'
}

exports.deployFile = function(program, cmd) {
  var ctx = checkOptions(program);
  checkOption(cmd, 'file', 'file');
  http.login(ctx, function(context) {
    fs.readFile(cmd.file, 'utf8', function(err, data) {
      if(err) {
        util.error("Failed to open file. " + err);
        process.exit(1);
      }
      if(cmd.setDefault)
        deployFile(context, data, setDefault);
      else
        deployFile(context, data);
    });
  });
}

exports.setDefault = function(program, cmd) {
  var ctx = checkOptions(program);
  checkOption(cmd, 'codeVersion', 'code-version');
  http.login(ctx, function(context) {
    setDefault(context, cmd.codeVersion);
  });
}

exports.downloadFile = function(program, cmd) {
  var ctx = checkOptions(program);
  checkOption(cmd, 'codeVersion', 'code-version');
  http.login(ctx, function(context) {
    downloadFile(context, cmd.codeVersion, cmd.outputFile);
  });
}

exports.listFiles = function(program, cmd) {
  var ctx = checkOptions(program);
  http.login(ctx, function(context) {
    listFiles(context);
  });
}

exports.deleteFile = function(program, cmd) {
  var ctx = checkOptions(program);
  checkOption(cmd, 'codeVersion', 'code-version');
  http.login(ctx, function(context) {
    deleteFile(context, cmd.codeVersion);
  });
}

/** options parsing */

function checkOptions(program) {
  if(!program.site && !program.siteUrl) {
    util.error("Either --site or --site-url is required");
    process.exit(1);
  }

  checkOption(program, 'appId', 'app-id');
  checkOption(program, 'appKey', 'app-key');

  if(!program.token && (!program.clientId || !program.clientSecret)) {
    util.error("Either --token or --client-id / --client-secret pair are required");
    process.exit(1);
  }

  return {
    url:          parseHost(program.site, program.siteUrl),
    appID:        program.appId,
    appKey:       program.appKey,
    clientID:     program.clientId,
    clientSecret: program.clientSecret,
    token:        program.token,
    basePath:     '/apps/' + program.appId + '/server-code',
    versionsPath: '/apps/' + program.appId + '/server-code/versions',
    debug:        program.debug != null && program.debug == true
  };
}

function checkOption(cmd, name, commandName) {
  if (!cmd[name]) {
    util.error("Missing param --" + commandName);    
    process.exit(1);
  }
}

function parseHost(site, siteUrl) {
  if(siteUrl != null) {
    var u = url.parse(siteUrl);
    if(['http:', 'https:'].indexOf(u.protocol) == -1) {
      util.error("Invalid protocol found, indicate either http or https in site url " + siteUrl);
      process.exit(1);
    }
    var p = u.protocol.substring(0, u.protocol.length - 1);
    return {
      host:     u.hostname,
      protocol: p,
      port:     u.port != null ? u.port : (p == 'http' ? 80 : 443),
      path:     u.pathname
    };    
  } else {
    h = hosts[site];
    if(h == null) {
      util.error("Undefined site found: " + site);
      process.exit(1);
    }
    return {
      host: h, protocol: 'https', port: 443, path: '/api'
    }
  } 
}


/** server code commands */

function deployFile(ctx, file, callback) {
  util.log('Deploying file...');
  var headers = { 'Content-Type' : 'application/javascript' };

  http.send(ctx, ctx.basePath, 'POST', headers, file, function(responseBody) {
    var versionID = JSON.parse(responseBody)['versionID'];
    util.log('File deployed as version ' + versionID);
    if(callback != null)
      callback(ctx, versionID);
  });  
}

function downloadFile(ctx, version, outputFile) {
  util.log('Downloading code version ' + version + '...');
  http.send(ctx, ctx.versionsPath + '/' + version, 'GET', {}, null, function(responseBody) {   
    if(outputFile) {
      fs.writeFile(outputFile, responseBody, function(err) {
        if(err) {
          util.log('Error accessing output file. ' + err);
          process.exit(1);
        } else {
          util.log("Code version written to " + outputFile);
        }
      }); 
    } else {
      util.log("Downloaded content: \n" + responseBody);
    }
  });
}

function listFiles(ctx) {
  util.log('Listing available versions...');
  http.send(ctx, ctx.versionsPath, 'GET', {}, null, function(responseBody) {
    var res = JSON.parse(responseBody);
    util.log("Found " + res.versions.length + " versions: ");
    res.versions.forEach(function(v, i, array) {
      util.log(v.versionID + ' ' + new Date(v.modifiedAt).toISOString() + ' ' + v.current);
    });
  });
}

function deleteFile(ctx, version) {
  util.log('Removing code version ' + version + '...');

  http.send(ctx, ctx.versionsPath + '/' + version, 'DELETE', {}, null, function(responseBody) {
    util.log('Version ' + version + ' removed');
  });
}

function setDefault(ctx, version) {     
  util.log('Setting default version to ' + version + '...');
  var headers = { 'Content-Type' : 'text/plain' }; 

  http.send(ctx, ctx.versionsPath + '/current', 'PUT', headers, version, function(responseBody) {
    util.log('Default version set to ' + version);
  });
}
