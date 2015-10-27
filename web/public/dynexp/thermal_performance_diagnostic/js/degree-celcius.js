App.filter('degreeCelcius', [function () {
  return function (input) {
    return input + "ºC";
  }
}]);