const PROXY_CONFIG = [{
  context: [
    "/device",
    "/logout",
    "/experiments",
    "/capabilities",
    "/protocols",
    "/ramps",
    "/settings",
    "/stages",
    "/steps",
    "/users",
    "/wells",
  ],
  target: "http://10.0.100.200",
  secure: false
}, {
  context: [
    "/login",
    "/welcome",
  ],
  target: "http://10.0.100.200",
  secure: false,
  bypass: function(req, res, proxyOptions) {
    if (req.method === 'GET') return '/index.html';
  }
}];

module.exports = PROXY_CONFIG;