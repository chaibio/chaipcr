window.ChaiBioTech.ngApp.filter('spaceToUnderscore', function () {
  return function (input) {
      return input.replace(/\s+/g,"_");
  };
});
