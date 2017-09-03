describe("Testing StepMovementRightService", function() {

    beforeEach(module('ChaiBioTech'));
    
    var _StepMovementRightService, _StepPositionService, _moveStepToSides; 

    beforeEach(inject(function(StepMovementRightService, StepPositionService, moveStepToSides) {
        _StepMovementRightService = StepMovementRightService;
        _StepPositionService = StepPositionService;
        _moveStepToSides = moveStepToSides;
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

    it("It should test ifOverRightSide method, check some method and its callback [ifOverRightSideCallback]", function() {

        spyOn(_StepMovementRightService, "ifOverRightSideCallback").and.callFake(function(s) {
            s.movedStepIndex = 10;
            return true;
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

        expect(_StepMovementRightService.ifOverRightSideCallback).toHaveBeenCalled();
    });

    it("It should test ifOverRightSideCallback", function() {

        var sI = {
            rightOffset: 20,
            currentMoveRight: 1,
            movement: {
                left: 90
            },
            kanvas: {
                allStepViews: [
                    {
                        moveToSide: function() {}
                    },
                    {
                        moveToSide: function() {}
                    }
                ]
            }
        };

        var args = [[50, 100, 150], 0];
        spyOn(_moveStepToSides, "moveToSide").and.returnValue(true);
        spyOn(_StepPositionService, "getPositionObject");

        _StepMovementRightService.ifOverRightSideCallback.apply(sI, args);

        expect(sI.currentMoveRight).toEqual(0);
        expect(_moveStepToSides.moveToSide).toHaveBeenCalled();
        expect(_StepPositionService.getPositionObject).toHaveBeenCalled();
    });

    it("It should test ifOverRightSideCallback, when positioning condition is not met", function() {

        var sI = {
            rightOffset: 20,
            currentMoveRight: 1,
            movement: {
                left: 20
            },
            kanvas: {
                allStepViews: [
                    {
                        moveToSide: function() {}
                    },
                    {
                        moveToSide: function() {}
                    }
                ]
            }
        };

        var args = [[50, 90, 150], 0];
        spyOn(sI.kanvas.allStepViews[0], "moveToSide").and.returnValue(true);
        spyOn(_StepPositionService, "getPositionObject");

        _StepMovementRightService.ifOverRightSideCallback.apply(sI, args);

        expect(sI.currentMoveRight).toEqual(1);
        expect(sI.kanvas.allStepViews[0].moveToSide).not.toHaveBeenCalled();
        expect(_StepPositionService.getPositionObject).not.toHaveBeenCalled();
    });

    it("It should test ifOverRightSideCallback, when position condition is met but index is already selected", function() {

        var sI = {
            rightOffset: 20,
            currentMoveRight: 0,
            movement: {
                left: 90
            },
            kanvas: {
                allStepViews: [
                    {
                        moveToSide: function() {}
                    },
                    {
                        moveToSide: function() {}
                    }
                ]
            }
        };

        var args = [[50, 100, 150], 0];
        spyOn(sI.kanvas.allStepViews[0], "moveToSide").and.returnValue(true);
        spyOn(_StepPositionService, "getPositionObject");

        _StepMovementRightService.ifOverRightSideCallback.apply(sI, args);

        expect(sI.currentMoveRight).toEqual(0);
        expect(sI.kanvas.allStepViews[0].moveToSide).not.toHaveBeenCalled();
        expect(_StepPositionService.getPositionObject).not.toHaveBeenCalled();
    });

    it("It should test movedRightAction method", function() {

        var sI = {
            rightOffset: 20,
            movedStepIndex: 0,
            currentMoveRight: 0,
            currentMoveLeft: 100,
            movement: {
                left: 90
            },
            kanvas: {
                allStepViews: [
                    {
                        moveToSide: function() {},
                        parentStage: {
                            index: 10
                        }
                    },
                    {
                        moveToSide: function() {}
                    }
                ]
            }
        };

        spyOn(_StepMovementRightService, "manageVerticalLineRight").and.returnValue(true);
        spyOn(_StepMovementRightService, "manageBorderLeftForRight").and.returnValue(true);

        _StepMovementRightService.movedRightAction(sI);
        expect(sI.currentDropStage.index).toEqual(10);
        expect(sI.currentMoveLeft).toEqual(null);
        expect(_StepMovementRightService.manageVerticalLineRight).toHaveBeenCalled();
        expect(_StepMovementRightService.manageVerticalLineRight).toHaveBeenCalled();
    });

    it("It should test manageVerticalLineRight method", function() {

        var sI = {
            verticalLine: {
                setLeft: function() {},
                setCoords: function() {},
            },
            rightOffset: 20,
            movedStepIndex: 0,
            currentMoveRight: 0,
            currentMoveLeft: 100,
            movement: {
                left: 90
            },
            kanvas: {
                allStepViews: [
                    {   
                        left: 20,
                        myWidth: 10,
                        moveToSide: function() {},
                        parentStage: {
                            index: 10
                        },
                        nextIsMoving: false,
                    },
                    {
                        moveToSide: function() {}
                    }
                ]
            }
        };

        spyOn(sI.verticalLine, "setLeft");
        spyOn(sI.verticalLine, "setCoords");

        _StepMovementRightService.manageVerticalLineRight(sI);
        expect(sI.verticalLine.setLeft).toHaveBeenCalledWith(28);
        expect(sI.verticalLine.setCoords).toHaveBeenCalled();
        
    });

    it("It should test manageVerticalLineRight method, when nextIsMoving set to true", function() {

        var sI = {
            verticalLine: {
                setLeft: function() {},
                setCoords: function() {},
            },
            rightOffset: 20,
            movedStepIndex: 0,
            currentMoveRight: 0,
            currentMoveLeft: 100,
            movement: {
                left: 90
            },
            kanvas: {
                moveDots: {
                    left: 50
                },
                allStepViews: [
                    {   
                        left: 20,
                        myWidth: 10,
                        moveToSide: function() {},
                        parentStage: {
                            index: 10
                        },
                        nextIsMoving: true,
                    },
                    {
                        moveToSide: function() {}
                    }
                ]
            }
        };

        spyOn(sI.verticalLine, "setLeft");
        spyOn(sI.verticalLine, "setCoords");

        _StepMovementRightService.manageVerticalLineRight(sI);
        expect(sI.verticalLine.setLeft).toHaveBeenCalledWith(57);
        expect(sI.verticalLine.setCoords).toHaveBeenCalled();
    });

    it("It should test manageBorderLeftForRight method", function() {

        var sI = {
            verticalLine: {
                setLeft: function() {},
                setCoords: function() {},
            },
            rightOffset: 20,
            movedStepIndex: 0,
            currentMoveRight: 0,
            currentMoveLeft: 100,
            movement: {
                left: 90
            },
            kanvas: {
                moveDots: {
                    left: 50
                },
                allStepViews: [
                    {
                        nextStep: {

                        },   
                        left: 20,
                        myWidth: 10,
                        moveToSide: function() {},
                        parentStage: {
                            index: 10
                        },
                        nextIsMoving: true,
                        borderLeft: {
                            setVisible: function() {}
                        }
                    },
                    {
                        moveToSide: function() {},
                        borderLeft: {
                            setVisible: function() {}
                        }
                    },
                    {
                        moveToSide: function() {},
                        borderLeft: {
                            setVisible: function() {}
                        }
                    }
                ]
            }
        };

        spyOn(sI.kanvas.allStepViews[1].borderLeft, "setVisible");
        spyOn(sI.kanvas.allStepViews[0].borderLeft, "setVisible");
        _StepMovementRightService.manageBorderLeftForRight(sI);
        expect(sI.kanvas.allStepViews[1].borderLeft.setVisible).toHaveBeenCalled();
        expect(sI.kanvas.allStepViews[0].borderLeft.setVisible).toHaveBeenCalled();

    });

    it("It should test manageBorderLeftForRight method, when nextStep is not available", function() {

        var sI = {
            verticalLine: {
                setLeft: function() {},
                setCoords: function() {},
            },
            rightOffset: 20,
            movedStepIndex: 0,
            currentMoveRight: 0,
            currentMoveLeft: 100,
            movement: {
                left: 90
            },
            kanvas: {
                moveDots: {
                    left: 50
                },
                allStepViews: [
                    {
                         
                        left: 20,
                        myWidth: 10,
                        moveToSide: function() {},
                        parentStage: {
                            index: 10
                        },
                        index: 0,
                        nextIsMoving: true,
                        borderLeft: {
                            setVisible: function() {}
                        }
                    },
                    {
                        moveToSide: function() {},
                        borderLeft: {
                            setVisible: function() {}
                        }
                    },
                    {
                        moveToSide: function() {},
                        borderLeft: {
                            setVisible: function() {}
                        }
                    }
                ]
            }
        };

        
        spyOn(sI.kanvas.allStepViews[0].borderLeft, "setVisible");
        _StepMovementRightService.manageBorderLeftForRight(sI);
        
        expect(sI.kanvas.allStepViews[0].borderLeft.setVisible).toHaveBeenCalled();

    });

});