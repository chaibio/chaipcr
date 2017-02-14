App.filter('degreeCelcius', [function () {
  return function (input) {
    input = input || 0;
    return input + "ºC";
  }
}]);