describe("Testing ChoosenChartService", function() {

    var _ChoosenChartService;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            mockCommonServices($provide);
        });

        inject(function($injector) {

            _ChoosenChartService = $injector.get('ChoosenChartService');
        });
    });

    it("It should test setCallback method", function() {

        var cb = "good";

        var retVal = _ChoosenChartService.setCallback(cb);
        expect(retVal).toEqual("good");
    });

    it("It should test chooseChart method", function() {

        var cb = function(chart) {
            return chart + " selected";
        };

        _ChoosenChartService.setCallback(cb);

        var retVal = _ChoosenChartService.chooseChart("Amplification Curve");
        expect(retVal).toEqual("Amplification Curve selected");
    });

    it("It should test chooseChart methodm when no callback", function() {

        var cb = function(chart) {
            return chart + " selected";
        };
        
        var retVal = _ChoosenChartService.chooseChart("Amplification Curve");
        expect(retVal).not.toEqual("Amplification Curve selected");
    });
});