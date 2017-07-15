const PROXY_CONFIG = [{
  context: [
    "/device",
    "/login",
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
}]

module.exports = PROXY_CONFIG;