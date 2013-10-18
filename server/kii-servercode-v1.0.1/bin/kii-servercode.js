#!/usr/bin/env node

var program = require('commander'),
    kii = require('../lib/kiiCommand');


executeCommand();

function executeCommand() {
  program
    .option('--site <site>', 'Site to be used. Eg: us, jp, cn.')
    .option('--site-url <url>', 'Full url of the api site. It will prevail over --site. Eg: https://api.kii.com/api')
    .option('--app-id <app-id>', 'App ID of the application. Eg: ab12cd34')
    .option('--app-key <app-key>', 'App Key of the application. Eg: jidmkljk1409kkdfhr21234iofew')
    .option('--client-id <client-id>', 'Client ID owner of the application. Eg: bc9d0209fkog')
    .option('--client-secret <client-secret>', 'Client secret of the owner of the application. Eg: kjlamcaduhjnqdcoadf88ijhfhundfadfg')
    .option('--token <token>', 'The token to be used. Can be used instead of client-id and client-secret to re-use an existing token')
    .option('--debug', 'Enable verbose mode');

  program.command('deploy-file')
    .option('--file <file>', 'Script to be deployed. Eg: /tmp/my-file.js')
    .option('--no-set-default', 'Do not set the newly-deployed versions as the default version')
    .action(function(cmd) {
      kii.deployFile(program, cmd);
    });

  // program.command('set-default')
  //   .action(function(cmd) {
  //     kii.setDefault(program, cmd);
  //   });

  program.command('get')
    .option('--code-version <version>', 'Version to be obtained. Eg: v12354')
    .option('--output-file <output-file>', 'Output file. Eg: /tmp/whatever.js')
    .action(function(cmd) {
      kii.downloadFile(program, cmd);
    });

  program.command('list')
    .action(function(cmd) {
      kii.listFiles(program, cmd);
    });

  program.command('delete')
    .option('--code-version <version>', 'Version to be deleted. Eg: v12354')
    .action(function(cmd) {
      kii.deleteFile(program, cmd);
    });

  // program.command('exec')
  //   .option('--endpoint-name <name>', 'Endpoint name to be executed. Eg: helloWorld')
  //   .action(function(cmd) {
  //     kii.execEndpoint(program, cmd);
  //   });

  program.parse(process.argv);

  // show help in case no command/params were found
  if (!program.args.length)
    program.help(); 
  // show help in case no command was found
  program.args.forEach(function(a) {
   if(typeof a == 'string')
      program.help(); 
  });
}