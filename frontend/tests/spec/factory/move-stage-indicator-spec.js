describe("Testing move-stage-indicator", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));
    
    var _moveStageIndicator;

    beforeEach(inject(function(moveStageIndicator) {

        var me = {
        };
        _moveStageIndicator = new moveStageIndicator(me);
        console.log(_moveStageIndicator);
    }));

    it("It should check if moveStageIndicator has stageName", function() {
        expect(_moveStageIndicator.stageName).toEqual(jasmine.any(Object));
    });

    it("It should check if moveStageIndicator has stageType", function() {
        expect(_moveStageIndicator.stageType).toEqual(jasmine.any(Object));
    });


});