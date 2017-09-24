describe("Testing moveStepToSides service", function() {

    var _moveStepToSides;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {

        });

        inject(function($injector) {
            _moveStepToSides = $injector.get('moveStepToSides');
        });
    });

    it("It should test moveToSide method, when direction === left", function() {

        var step = {
            stepMovedDirection: "right",
            left: 100,
            moveStep: function() {},
            circle: {
                moveCircleWithStep: function() {}
            },
        };

        spyOn(step, "moveStep");
        spyOn(step.circle, "moveCircleWithStep");
        spyOn(_moveStepToSides, "adjustDotsPlacingLeft").and.returnValue();

        _moveStepToSides.moveToSide(step, "left");

        expect(step.moveStep).toHaveBeenCalled();
        expect(step.circle.moveCircleWithStep).toHaveBeenCalled();
        expect(_moveStepToSides.adjustDotsPlacingLeft).toHaveBeenCalled();
        expect(step.stepMovedDirection).toEqual("left");
        expect(step.left).toEqual(90);
    });

    it("It should test moveToSide method, when direction === right", function() {

        var step = {
            stepMovedDirection: "left",
            left: 100,
            moveStep: function() {},
            circle: {
                moveCircleWithStep: function() {}
            },
        };

        spyOn(step, "moveStep");
        spyOn(step.circle, "moveCircleWithStep");
        spyOn(_moveStepToSides, "adjustDotsPlacingRight").and.returnValue();

        _moveStepToSides.moveToSide(step, "right");

        expect(step.moveStep).toHaveBeenCalled();
        expect(step.circle.moveCircleWithStep).toHaveBeenCalled();
        expect(_moveStepToSides.adjustDotsPlacingRight).toHaveBeenCalled();
        expect(step.stepMovedDirection).toEqual("right");
        expect(step.left).toEqual(110);
    });

    it("It should test adjustDotsPlacingRight method", function() {

        var step = {
            left: 100,
            myWidth: 50,
            nextIsMoving: true,
            parentStage: {
                parent: {
                    moveDots: {
                        setLeft: function() {},
                        setCoords: function() {},
                        setVisible: function() {},
                    }
                }
            }
        };

        spyOn(step.parentStage.parent.moveDots, "setLeft");
        spyOn(step.parentStage.parent.moveDots, "setCoords");
        spyOn(step.parentStage.parent.moveDots, "setVisible");

        _moveStepToSides.adjustDotsPlacingRight(step);

        expect(step.parentStage.parent.moveDots.setLeft).toHaveBeenCalledWith(step.left + step.myWidth + 6);
        expect(step.parentStage.parent.moveDots.setCoords).toHaveBeenCalled();
        expect(step.parentStage.parent.moveDots.setVisible).toHaveBeenCalledWith(true);
    });

    it("It should test adjustDotsPlacingLeft method", function() {

        var step = {
            left: 100,
            myWidth: 50,
            nextIsMoving: true,
            previousIsMoving: true,
            previousStep: {
                left: 200,
                myWidth: 50
            },
            parentStage: {
                parent: {
                    moveDots: {
                        setLeft: function() {},
                        setCoords: function() {},
                        setVisible: function() {},
                    }
                }
            }
        };

        spyOn(step.parentStage.parent.moveDots, "setLeft");
        spyOn(step.parentStage.parent.moveDots, "setCoords");
        spyOn(step.parentStage.parent.moveDots, "setVisible");

        _moveStepToSides.adjustDotsPlacingLeft(step);

        expect(step.parentStage.parent.moveDots.setLeft).toHaveBeenCalledWith(step.previousStep.left + step.previousStep.myWidth + 6);
        expect(step.parentStage.parent.moveDots.setCoords).toHaveBeenCalled();
        expect(step.parentStage.parent.moveDots.setVisible).toHaveBeenCalledWith(true);

    });
});