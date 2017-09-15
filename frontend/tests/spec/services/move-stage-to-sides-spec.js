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

    it("It should test moveToSideStageComponents method", function() {

        var moveCount = 30;
        var targetStage = {
            stageGroup: {
                setCoords: function() {},
                set: function() {},
            },
            dots: {
                set: function() {},
                setCoords: function() {}
            },
            left: 50,
            childSteps: [
                {
                    moveStep: function() {},
                    circle: {
                        moveCircleWithStep: function() {}
                    }
                }
            ],
            sourceStage: true,
        };

        spyOn(_moveStageToSides, "manageSourceStageStepMovement").and.returnValue(true);

        spyOn(targetStage.stageGroup, "set");
        spyOn(targetStage.dots, "set");
        
        spyOn(targetStage.childSteps[0], "moveStep");
        spyOn(targetStage.childSteps[0].circle, "moveCircleWithStep");
        
        _moveStageToSides.moveToSideStageComponents(moveCount, targetStage);
        
        expect(targetStage.stageGroup.set).toHaveBeenCalled();
        expect(targetStage.dots.set).toHaveBeenCalled();
        expect(targetStage.left).toEqual(50 + moveCount);
        expect(targetStage.childSteps[0].moveStep).toHaveBeenCalled();
        expect(targetStage.childSteps[0].circle.moveCircleWithStep).toHaveBeenCalled();
        expect(_moveStageToSides.manageSourceStageStepMovement).toHaveBeenCalled();
    });

    it("It should test manageSourceStageStepMovement method", function() {

        var targetStage = {
            childSteps: [
                {
                    previousIsMoving: true,
                    left: 10,
                    moveStep: function() {},
                    circle: {
                        moveCircleWithStep: function() {}
                    },

                }
            ],
            
                parent: {
                    moveDots: {
                        setLeft: function() {},
                        setCoords: function() {},
                    }
                }
           
        };

        spyOn(targetStage.childSteps[0], "moveStep");
        spyOn(targetStage.childSteps[0].circle, "moveCircleWithStep");
        spyOn(targetStage.parent.moveDots, "setLeft");

        _moveStageToSides.manageSourceStageStepMovement(targetStage);

        expect(targetStage.childSteps[0].moveStep).toHaveBeenCalled();
        expect(targetStage.childSteps[0].circle.moveCircleWithStep).toHaveBeenCalled();
        expect(targetStage.parent.moveDots.setLeft).toHaveBeenCalledWith(targetStage.left + 6);
        expect(targetStage.childSteps[0].left).toEqual(50);
    });

    it("It should test manageSourceStageStepMovement method when moveDots has baseStage", function() {
        var targetStage = {
            childSteps: [
                {
                    previousIsMoving: true,
                    left: 10,
                    moveStep: function() {},
                    circle: {
                        moveCircleWithStep: function() {}
                    },

                }
            ],
            
                parent: {
                    moveDots: {
                        baseStep: {
                            left: 100,
                            myWidth: 128,
                        },
                        setLeft: function() {},
                        setCoords: function() {},
                    }
                }
           
        };

        var baseStep = targetStage.parent.moveDots.baseStep;

        spyOn(targetStage.childSteps[0], "moveStep");
        spyOn(targetStage.childSteps[0].circle, "moveCircleWithStep");
        spyOn(targetStage.parent.moveDots, "setLeft");

        _moveStageToSides.manageSourceStageStepMovement(targetStage);

        expect(targetStage.childSteps[0].moveStep).toHaveBeenCalled();
        expect(targetStage.childSteps[0].circle.moveCircleWithStep).toHaveBeenCalled();
        expect(targetStage.parent.moveDots.setLeft).toHaveBeenCalledWith(baseStep.left + baseStep.myWidth + 6);
        expect(targetStage.childSteps[0].left).toEqual(50);
    });
    
});