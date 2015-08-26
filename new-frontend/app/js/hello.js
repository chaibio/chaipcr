window.helloText = function() {
  return 'Hello, World!';
};

window.hello = function() {
  console.log("qwesome");
  html = JST['app/templates/hello.us']({text: helloText()});
  document.body.innerHTML += html;
};

if(window.addEventListener) {
  window.addEventListener('DOMContentLoaded', hello, false);
} else {
  window.attachEvent('onload', hello);
}
