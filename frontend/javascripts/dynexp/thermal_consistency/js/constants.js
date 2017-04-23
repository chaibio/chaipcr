(function () {

  angular.module('dynexp.thermal_consistency').value('ThermalConsistencyConstants', {
    MIN_FLUORESCENCE_VAL: 8000000,
    MIN_TM_VAL: 77,
    MAX_TM_VAL: 81,
    MAX_DELTA_TM_VAL: 2
  });

})();