window.ChaiBioTech.ngApp.filter('preZero', [
  function() {
    return function(value, addition) {

      if(isNaN(value)) {
        return "";
      }

      value = (value < 10) ? "0" + value : value;
      value = (angular.isDefined(addition)) ? addition + value : value;
      return value;
    };
  }
]);
