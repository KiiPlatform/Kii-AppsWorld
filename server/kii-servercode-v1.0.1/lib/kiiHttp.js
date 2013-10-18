var https = require('https'),
    http = require('http'),
    util = require('util');

exports.login = function(ctx, callback) {
  login(ctx, callback);
}

exports.send = function(ctx, path, method, headers, body, callback) {
  send(ctx, path, method, headers, body, callback);
}

function login(ctx, callback) {
  if(ctx.token != null) {
    if(ctx.debug)
      util.log('Using token ' + ctx.token + ' for authentication');
    return callback(ctx);
  }

  if(ctx.debug)
    util.log("Using client-id = " + ctx.clientID + " and client-secret = " 
      + ctx.clientSecret + " for authentication");

  var tokenRequest = JSON.stringify({
    'client_id': ctx.clientID,
    'client_secret': ctx.clientSecret
  }, null, 2);

  var options = {
    hostname: ctx.url.host, port: ctx.url.port, path: normalize(ctx.url.path) + '/oauth2/token',
    method: 'POST',
    headers: {
      'X-Kii-AppID': ctx.appID, 'X-Kii-AppKey': ctx.appKey,
      'Content-Type' : 'application/json',
      'Content-Length': tokenRequest.length
    }
  };

  if(ctx.debug) {
    util.log("REQUEST:\n" + JSON.stringify(options, null, 2));
    util.log("REQUEST body:\n" + tokenRequest);
  }

  var req = client(ctx.url.protocol).request(options, function(response) {
    response.setEncoding('utf-8');

    var responseBody = "";
    response.on('data', function(data) { responseBody += data; });

    response.on('end', function() {
      if(ctx.debug) {     
        util.log('RESPONSE status: ' + response.statusCode);
        util.log('RESPONSE headers:\n' + JSON.stringify(response.headers, null, 2));
        util.log('RESPONSE body: \n' + responseBody);
      }

      if(hasError(response)) {
        util.error('Failed to authenticate: ' + response.statusCode + ' - (' + responseBody + ')');
        util.error('Check your app-id, app-key, client-id & client-secret.');
        util.error('Execution context: ' + JSON.stringify(ctx, null, 2));
        process.exit(1);
      }
      ctx.token = JSON.parse(responseBody)['access_token'];
      callback(ctx);
    });
  });

  req.on('error', errorLogger);

  req.write(tokenRequest);
  req.end();
}

function send(ctx, path, method, headers, body, callback) {
  var options = {
    hostname: ctx.url.host, port: ctx.url.port, path: normalize(ctx.url.path) + path,
    method: method,
    headers: {
      'X-Kii-AppID': ctx.appID, 'X-Kii-AppKey': ctx.appKey,
      'Authorization': 'Bearer ' + ctx.token ,
      'Content-Length': body != null ? Buffer.byteLength(body, 'utf8') : 0
    }
  };

  for(var k in headers)
    options.headers[k] = headers[k];
  
  if(ctx.debug) {
    util.log("REQUEST: \n" + JSON.stringify(options, null, 2));
    if(body != null)
      util.log("REQUEST body: \n" + body);
  }
  
  var req = client(ctx.url.protocol).request(options, function(response) {

    var responseBody = "";
    response.on('data', function(data) { responseBody += data; });

    response.on('end', function() {
      if(ctx.debug) {     
        util.log('RESPONSE status: ' + response.statusCode);
        util.log('RESPONSE headers:\n' + JSON.stringify(response.headers, null, 2));      
        util.log('RESPONSE body: \n' + responseBody);
      }

      if(hasError(response)) {
        var jsonType = /json/g;
        var mediaType = response.headers['content-type'];
        
        if(jsonType.test(mediaType)) 
          util.error('Error found: ' + responseBody);
        else 
          util.error('Http error found: http code ' + response.statusCode + ' - body: ' + responseBody);
        
        process.exit(1);
      }         

      callback(responseBody);
    })
  });

  req.on('error', errorLogger);

  if(body != null)
    req.write(body, 'utf8');

  req.end();
}

/** utils */

function hasError(response) {
  return response.statusCode > 399;
}

function errorLogger(e) { 
  util.error('Error found while serving request: ' + e.message + ' - ' + e.stack); 
}

function client(protocol) {
  return protocol == 'http' ? http : https;
}

function normalize(path) {
  return path.substring(path.length - 1) == '/' ?
    path.substring(0, path.length -1) : path;
}