window.ChaiBioTech.ngApp.filter('toHour', [
  '$filter',
  function($filter) {
    return function(value) {

      if(isNaN(value)) {
        return "";
      }
      var preZero = $filter('preZero');
      value = parseInt(value);
      var hrs = parseInt(value / 3600);
      var min = parseInt((value % 3600) / 60);
      var sec = (value % 60);

      return preZero(hrs) + ":" + preZero(min) + ":" + preZero(min);
    };
  }
]);
