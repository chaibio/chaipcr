# Angular 2 Build Process

### Development

 - cd to `ng2` directory
 - install node modules if not yet done by `npm install`
 - run development server by `npm start`
 - navigate to [http://127.0.0.1:4200](http://127.0.0.1:4200)

~~When working in development environment, all calls to apis are passed to `10.0.100.200` test machine using Angular CLI proxy, so make sure you are connected to Chai VPN. The proxy configuration can be found in [proxy.conf.js](./proxy.conf.js).~~

~~Edit: `proxy.conf.js` has been added to `.gitignore` list. Use `proxy.conf.js.example` as reference to setup your proxy.~~

Edit: In development, all calls to api are sent to local rails web server (`localhost:3000`).

You can read more about [Angular CLI Proxy](https://github.com/angular/angular-cli/blob/master/docs/documentation/stories/proxy.md)

### Deployment

 - cd to project's root directory `chaipcr`
 - run `gulp ng2:deploy`
 - run the deploy script `./deploy.sh <remote_IP>`
