describe("Testing StepMovementRightService", function() {

    beforeEach(module('ChaiBioTech'));
    
    var _StepMovementRightService, _StepPositionService; 

    beforeEach(inject(function(StepMovementRightService, StepPositionService) {
        _StepMovementRightService = StepMovementRightService;
        _StepPositionService = StepPositionService;
    }));

    it("It should test ifOverRightSide method", function() {

        spyOn(_StepMovementRightService, "ifOverRightSideCallback").and.callFake(function(s) {
            s.movedStepIndex = 10;
        });

        _StepPositionService.allPositions = {
            some: function(callBack, sI) {
                callBack(sI);
            }
        };
        var sI = {
            movedStepIndex: null
        };
       
        _StepMovementRightService.ifOverRightSide(sI);

        expect(sI.movedStepIndex).toEqual(10);
    });

    it("It should test ifOverRightSide method, check some method", function() {

        spyOn(_StepMovementRightService, "ifOverRightSideCallback").and.callFake(function(s) {
            s.movedStepIndex = 10;
        });

        _StepPositionService.allPositions = {
            some: function(callBack, sI) {
                callBack(sI);
            }
        };
        var sI = {
            movedStepIndex: null
        };
        spyOn(_StepPositionService.allPositions, "some");
        _StepMovementRightService.ifOverRightSide(sI);

        expect(_StepPositionService.allPositions.some).toHaveBeenCalled();
    });
});