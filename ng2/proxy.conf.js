const PROXY_CONFIG = [{
  context: [
    "/device",
  ],
  target: "http://10.0.100.200",
  secure: false
}]

module.exports = PROXY_CONFIG;