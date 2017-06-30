describe("Testing StageMovementRightService", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));

    var _StageMovementRightService, _StagePositionService, _StepPositionService;

    beforeEach(inject(function(StageMovementRightService, StagePositionService, StepPositionService) {

        _StageMovementRightService = StageMovementRightService;
        _StagePositionService = StagePositionService;
        _StepPositionService = StepPositionService;
    }));

    it("It should test shouldStageMoveRight method", function() {

        sI = {
            movedStageIndex: null
        };

        spyOn(_StageMovementRightService, "shouldStageMoveRightCallback").and.callFake(function(thisObjs) {
            thisObjs.movedStageIndex = 5;
            return true;
        });

        _StagePositionService.allPositions = {
            
            some: function(callback, thisObjs) {
                callback(thisObjs);
            }
        };

        var rVal = _StageMovementRightService.shouldStageMoveRight(sI);
        expect(rVal).toEqual(5);
    });

    it("It should test shouldStageMoveLeft method, test shouldStageMoveRightCallback call from this method", function() {

        sI = {
            movedStageIndex: null
        };

        spyOn(_StageMovementRightService, "shouldStageMoveRightCallback").and.callFake(function(thisObjs) {
            thisObjs.movedStageIndex = 5;
            return true;
        });

        _StagePositionService.allPositions = {
            
            some: function(callback, thisObjs) {
                callback(thisObjs);
            }
        };

        _StageMovementRightService.shouldStageMoveRight(sI);
         expect(_StageMovementRightService.shouldStageMoveRightCallback).toHaveBeenCalled();
    });

}); 