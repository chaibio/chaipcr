describe("Testing StepMoveVoidSpaceLeftService", function() {

    beforeEach(module('ChaiBioTech'));

    var _StepMoveVoidSpaceLeftService, _StagePositionService;

    beforeEach(inject(function(StepMoveVoidSpaceLeftService, StagePositionService) {
        _StagePositionService = StagePositionService;
        _StepMoveVoidSpaceLeftService = StepMoveVoidSpaceLeftService;
    }));

    it("It should test checkVoidSpaceLeft method", function() {

        _StagePositionService.allVoidSpaces = {
            some: function(callback, obj) {
                callback(obj);
            }
        };

        spyOn(_StagePositionService.allVoidSpaces, "some");
        _StepMoveVoidSpaceLeftService.checkVoidSpaceLeft({});
        expect(_StagePositionService.allVoidSpaces.some).toHaveBeenCalled();
    });

    it("It should test checkVoidSpaceLeft method and check some methods callback", function() {

        _StagePositionService.allVoidSpaces = {
            some: function(callback, obj) {
                callback(obj);
            }
        };

        spyOn(_StepMoveVoidSpaceLeftService, "voidSpaceCallbackLeft").and.callFake(function() {
            return true;
        });
        _StepMoveVoidSpaceLeftService.checkVoidSpaceLeft({});
        expect(_StepMoveVoidSpaceLeftService.voidSpaceCallbackLeft).toHaveBeenCalled();
    });
});