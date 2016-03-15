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

})();