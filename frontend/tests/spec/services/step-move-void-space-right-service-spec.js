describe("Testing StepMoveVoidSpaceRightService", function() {

    beforeEach(module('ChaiBioTech'));

    var _StepMoveVoidSpaceRightService, _StagePositionService;
    
    beforeEach(inject(function(StepMoveVoidSpaceRightService, StagePositionService) {
        _StepMoveVoidSpaceRightService = StepMoveVoidSpaceRightService;
        _StagePositionService = StagePositionService;
    }));

    it("It should test checkVoidSpaceRight", function() {

        _StagePositionService.allVoidSpaces = {
            some: function(callBack, context) {
                callBack(context);
            }
        };

        spyOn(_StepMoveVoidSpaceRightService, "voidSpaceCallbackRight").and.callFake(function(s) {
            return true;
        });

        spyOn(_StagePositionService.allVoidSpaces, "some");

        _StepMoveVoidSpaceRightService.checkVoidSpaceRight({});

        expect(_StagePositionService.allVoidSpaces.some).toHaveBeenCalled();
        
    });

    it("It should test checkVoidSpaceRight", function() {

        _StagePositionService.allVoidSpaces = {
            some: function(callBack, context) {
                callBack(context);
            }
        };

        spyOn(_StepMoveVoidSpaceRightService, "voidSpaceCallbackRight").and.callFake(function(s) {
            return true;
        });

        _StepMoveVoidSpaceRightService.checkVoidSpaceRight({});

        expect(_StepMoveVoidSpaceRightService.voidSpaceCallbackRight).toHaveBeenCalled();
    });
});