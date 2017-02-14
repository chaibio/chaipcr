(function () {

  App.filter('round', [
    function() {
      return function(input, numDigit) {
        var num;
        num = parseFloat(input) || 0;
        return num.toFixed(numDigit);
      };
    }
  ]);

  App.filter('commaSeparated', [
    function () {
      return function (input) {
        return Math.round(input).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
      };
    }
  ]);

})();