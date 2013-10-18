kii-servercode
==============

Every command execution requires at least the following context information: site, app-id, app-key, client-id and client-secret or token.
Currently this context information needs to be passed in every execution, but this should change in the future.

## Install
```
npm install
sudo npm link
```

## Basic Usage

  Usage: kii-servercode.js [options] [command]

  Commands:

    deploy-file [options] 
    get [options]         
    list                  
    delete [options]      

  Options:

    -h, --help                       output usage information
    --site <site>                    Site to be used. Eg: us, jp.
    --site-url <url>                 Full url of the api site. It will prevail over --site. Eg: https://api.kii.com/api
    --app-id <app-id>                App ID of the application. Eg: ab12cd34
    --app-key <app-key>              App Key of the application. Eg: jidmkljk1409kkoqerqpokjd234iofew
    --client-id <client-id>          Client ID owner of the application. Eg: bc9d0209fkog
    --client-secret <client-secret>  Client secret of the owner of the application. Eg: kjlamcaduhjnqi92jdn18adf88ijhfhundfadfg
    --token <token>                  The token to be used. Can be used instead of client-id and client-secret to re-use an existing token
    --debug                          Enable verbose mode

## Deploy a File

  Usage: deploy-file [options]

  Options:

    -h, --help     output usage information
    --file <file>  Script to be deployed. Eg: /tmp/my-file.js
    --no-set-default  Do not set the newly-deployed versions as the default version

  Example:

    node kii-servercode.js deploy-file --file demo.js \
    --site us --app-id demoapp --app-key jhhjd87y8yi --client-id 898weerih9e98 --client-secret ugh08wyiuhdskjhsdjf

<!---
## Set Default Version

  Usage: set-default [options]

  Options:

    -h, --help  output usage information

  Example:

    node kii-servercode.js set-default \
    --site us --app-id demoapp --app-key jhhjd87y8yi --client-id 898weerih9e98 --client-secret ugh08wyiuhdskjhsdjf
-->
## Get a File

  Usage: get [options]

  Options:

    -h, --help                   output usage information
    --code-version <version>     Version to be obtained. Eg: v12354
    --output-file <output-file>  Output file. Eg: /tmp/whatever.js

  Example:

    node kii-servercode.js get --code-version hvfejfhvg \
    --site us --app-id demoapp --app-key jhhjd87y8yi --client-id 898weerih9e98 --client-secret ugh08wyiuhdskjhsdjf

## List Available Versions

  Usage: list [options]

  Options:

    -h, --help  output usage information

  Example:

    node kii-servercode.js list \
    --site us --app-id demoapp --app-key jhhjd87y8yi --client-id 898weerih9e98 --client-secret ugh08wyiuhdskjhsdjf

## Delete a File

  Usage: delete [options]

  Options:

    -h, --help                output usage information
    --code-version <version>  Version to be deleted. Eg: v12354

  Example:

    node kii-servercode.js delete --code-version ghfdgfdg \
    --site us --app-id demoapp --app-key jhhjd87y8yi --client-id 898weerih9e98 --client-secret ugh08wyiuhdskjhsdjf
