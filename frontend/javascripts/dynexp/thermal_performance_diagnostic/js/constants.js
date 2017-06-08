(function() {

	angular.module('dynexp.thermal_performance_diagnostic')
	.value('ThermalPerformanceDiagnosticConstants', {

		HEATING: {
			MIN_AVG_RAMP_RATE: 2, // C/s
			MAX_TOTAL_TIME: 22.5, // s
			MAX_BLOCK_DELTA: 0.85 //C
		},

		COOLING: {
			MIN_AVG_RAMP_RATE: 2, // C/s
			MAX_TOTAL_TIME: 22.5, // s
			MAX_BLOCK_DELTA: 0.85 //C
		},

		LID: {
			MIN_HEATING_RATE: 1, //C
			MAX_TIME_TO_HEAT: 90 //s
		}

	});
})();
