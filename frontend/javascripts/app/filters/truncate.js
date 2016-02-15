window.ChaiBioTech.ngApp.filter('truncate', [
  function() {
    return function(value, length) {

      var MAX_VALUE = length || 32;

      if(!value) {
        return '';
      }

      if(value.length <= 32) {
        return value;
      }

      return value.substring(0, MAX_VALUE - 2) + ' ...';
    };
  }
]);
