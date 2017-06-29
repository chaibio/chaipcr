describe("Testing StageMovementLeftService", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));

    var _StageMovementLeftService, _StagePositionService;

    beforeEach(inject(function(StageMovementLeftService, StagePositionService) {

        _StageMovementLeftService = StageMovementLeftService;
        _StagePositionService = StagePositionService;
    }));

    it("It should test shouldStageMoveLeft method", function() {

        sI = {
            movedStageIndex: null
        };

        spyOn(_StageMovementLeftService, "shouldStageMoveLeftCallback").and.callFake(function(thisObjs) {
            thisObjs.movedStageIndex = 5;
            return true;
        });

        _StagePositionService.allPositions = {
            
            some: function(callback, thisObjs) {
                callback(thisObjs);
            }
        };

        var rVal = _StageMovementLeftService.shouldStageMoveLeft(sI);
        expect(rVal).toEqual(5);
    });
});