describe("Testing moveStageToSides service", function() {

    var _moveStageToSides;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

        });

        inject(function($injector) {
            _moveStageToSides = $injector.get('moveStageToSides');
        });
    });

    it("It should test moveToSide method when validMove() return false", function() {

        spyOn(_moveStageToSides, "validMove").and.returnValue(false);

        var rValue = _moveStageToSides.moveToSide("left", {}, {});

        expect(rValue).toEqual(null);
    });

    it("It should test moveToSide method when validMove() return true and direction === left", function() {

        var draggedStage = {};
        var targetStage = {};
        var direction = "left";

        spyOn(_moveStageToSides, "validMove").and.returnValue(true);
        spyOn(_moveStageToSides, "makeSurePreviousMovedLeft");
        spyOn(_moveStageToSides, "makeSureNextMovedRight");
        spyOn(_moveStageToSides, "moveToSideStageComponents").and.returnValue(true);

        var rValue = _moveStageToSides.moveToSide(direction, draggedStage, targetStage);

        expect(rValue).toEqual("Valid Move");
        expect(_moveStageToSides.moveToSideStageComponents).toHaveBeenCalled();
        expect(_moveStageToSides.makeSurePreviousMovedLeft).toHaveBeenCalled();
        expect(_moveStageToSides.makeSureNextMovedRight).not.toHaveBeenCalled();
        expect(targetStage.stageMovedDirection).toEqual("left");
    });

    it("It should test moveToSide method when validMove() return true and direction === right", function() {

        var draggedStage = {};
        var targetStage = {};
        var direction = "right";

        spyOn(_moveStageToSides, "validMove").and.returnValue(true);
        spyOn(_moveStageToSides, "makeSurePreviousMovedLeft");
        spyOn(_moveStageToSides, "makeSureNextMovedRight");
        spyOn(_moveStageToSides, "moveToSideStageComponents").and.returnValue(true);

        var rValue = _moveStageToSides.moveToSide(direction, draggedStage, targetStage);

        expect(rValue).toEqual("Valid Move");
        expect(_moveStageToSides.moveToSideStageComponents).toHaveBeenCalled();
        expect(_moveStageToSides.makeSurePreviousMovedLeft).not.toHaveBeenCalled();
        expect(_moveStageToSides.makeSureNextMovedRight).toHaveBeenCalled();
        expect(targetStage.stageMovedDirection).toEqual("right");
    });

    it("It should test makeSurePreviousMovedLeft method", function() {

        var draggedStage = {

        };

        var targetStage = {
            previousStage: {
                stageMovedDirection: "right"
            }
        };

        spyOn(_moveStageToSides, "moveToSide").and.returnValue(true);

        _moveStageToSides.makeSurePreviousMovedLeft(draggedStage, targetStage);

        expect(_moveStageToSides.moveToSide).toHaveBeenCalled();
    });

    it("It should test makeSureNextMovedRight method", function() {

        var draggedStage = {

        };

        var targetStage = {
            nextStage: {
                stageMovedDirection: "left"
            }
        };

        spyOn(_moveStageToSides, "moveToSide").and.returnValue(true);

        _moveStageToSides.makeSureNextMovedRight(draggedStage, targetStage);

        expect(_moveStageToSides.moveToSide).toHaveBeenCalled();
    });
});