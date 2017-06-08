angular.module('dynexp.optical_test_single_channel')

.filter('commaSeparated', [
  function() {
    return function(input) {
      return Math.round(input).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    };
  }
]);
