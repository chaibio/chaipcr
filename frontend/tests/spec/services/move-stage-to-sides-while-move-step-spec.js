describe("Testing moveStageToSidesWhileMoveStep method", function() {

    var _moveStageToSidesWhileMoveStep, _moveStageToSides;

    beforeEach(function() {
        module("ChaiBioTech", function($provide) {

        });

        inject(function($injector) {
            _moveStageToSides = $injector.get("moveStageToSides");
            _moveStageToSidesWhileMoveStep = $injector.get("moveStageToSidesWhileMoveStep");
        });

    });

    it("It should test moveToSideForStep method when direction === left", function() {

        var direction = "left";
        var targetStage = {};

        spyOn(_moveStageToSidesWhileMoveStep, "moveStageToLeft").and.returnValue(true);
        spyOn(_moveStageToSidesWhileMoveStep, "moveStageToRight").and.returnValue(true);

        _moveStageToSidesWhileMoveStep.moveToSideForStep(direction, targetStage);

        expect(_moveStageToSidesWhileMoveStep.moveStageToLeft).toHaveBeenCalled();
        expect(_moveStageToSidesWhileMoveStep.moveStageToRight).not.toHaveBeenCalled();
    });

    it("It should test moveToSideForStep method when direction === right", function() {

        var direction = "right";
        var targetStage = {};

        spyOn(_moveStageToSidesWhileMoveStep, "moveStageToLeft").and.returnValue(true);
        spyOn(_moveStageToSidesWhileMoveStep, "moveStageToRight").and.returnValue(true);

        _moveStageToSidesWhileMoveStep.moveToSideForStep(direction, targetStage);

        expect(_moveStageToSidesWhileMoveStep.moveStageToLeft).not.toHaveBeenCalled();
        expect(_moveStageToSidesWhileMoveStep.moveStageToRight).toHaveBeenCalled();
    });

    it("It should test moveStageToRight method when direction != right", function() {

        var stage = {
            stageMovedDirection: "left",
            nextStage: null,
        };

        spyOn(_moveStageToSides, "moveToSideStageComponents").and.returnValue(true);
        
        _moveStageToSidesWhileMoveStep.moveStageToRight(stage);

        expect(_moveStageToSides.moveToSideStageComponents).toHaveBeenCalled();
        expect(stage.stageMovedDirection).toEqual("right");

    });

    it("It should test moveStageToRight method when direction === right", function() {

        var stage = {
            stageMovedDirection: "right",
            nextStage: null,
        };

        spyOn(_moveStageToSides, "moveToSideStageComponents").and.returnValue(true);
        
        _moveStageToSidesWhileMoveStep.moveStageToRight(stage);

        expect(_moveStageToSides.moveToSideStageComponents).not.toHaveBeenCalled();

    });

    it("It should test moveStageToLeft method when stageMovedDirection === null", function() {

        var stage = {
            stageMovedDirection: null,
            nextStage: {
                stageMovedDirection: null,
            },
        };

        spyOn(_moveStageToSidesWhileMoveStep, "moveStageToRight").and.returnValue(true);

        _moveStageToSidesWhileMoveStep.moveStageToLeft(stage);

        expect(_moveStageToSidesWhileMoveStep.moveStageToRight).toHaveBeenCalled();
    });

    it("It should test moveStageToLeft method when stageMovedDirection === left", function() {

        var stage = {
            stageMovedDirection: "left",
            nextStage: null
        };

        spyOn(_moveStageToSidesWhileMoveStep, "moveStageToRight").and.returnValue(true);

        _moveStageToSidesWhileMoveStep.moveStageToLeft(stage);

        expect(_moveStageToSidesWhileMoveStep.moveStageToRight).not.toHaveBeenCalled();
    });

    it("It should test moveStageToLeft method when stageMovedDirection !== left", function() {

        var stage = {
            stageMovedDirection: "null",
            previousStage: {
                stageMovedDirection: "right"
            }
        };

        spyOn(_moveStageToSides, "moveToSideStageComponents").and.returnValue(true);

        _moveStageToSidesWhileMoveStep.moveStageToLeft(stage);

        expect(_moveStageToSides.moveToSideStageComponents).toHaveBeenCalled();
        expect(stage.stageMovedDirection).toEqual("left");
    });

});