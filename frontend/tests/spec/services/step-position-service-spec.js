describe("Testing StepPositionService", function() {

    beforeEach(module('ChaiBioTech'));

    var _StepPositionService;
    beforeEach(inject(function(StepPositionService) {
        _StepPositionService = StepPositionService;
    }));

    it("It should test the init method", function() {

        _StepPositionService.init("test");
        expect(_StepPositionService.allSteps).toEqual("test");
    });

    it("It should test getPositionObject method when, allSteps is null", function() {

        _StepPositionService.allSteps = null;
        var rValue = _StepPositionService.getPositionObject();
        expect(rValue).toEqual(null);
    });

});