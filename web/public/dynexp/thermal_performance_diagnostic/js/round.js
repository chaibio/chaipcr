

(function () {

  App.filter('round', [
    function() {
      return function(input, numDigit) {
        var num;
        num = parseFloat(input);
        return num.toFixed(numDigit);
      };
    }
  ]);

})();