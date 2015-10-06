window.ChaiBioTech.ngApp.filter('csUnit', [
  function() {
    return function(value, unit) {

      if(unit === "C/s") {
        console.log("value", value, unit);
        return value;
      }
      return value;
    };
  }
]);
