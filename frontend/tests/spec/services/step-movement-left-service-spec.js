describe("Testing StepMovementLeftService", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));

  var _StepMovementLeftService, _StepPositionService, _moveStepToSides;

  beforeEach(inject(function(StepMovementLeftService, StepPositionService, moveStepToSides) {
    _StepPositionService = StepPositionService;
    _StepMovementLeftService = StepMovementLeftService;
    _moveStepToSides = moveStepToSides;
  }));

  it("It should test ifOverLeftSide method checking movedStepIndex", function() {

    spyOn(_StepMovementLeftService, "ifOverLeftSideCallback").and.callFake(function(sI) {
      sI.movedStepIndex = 10;
      return true;
    });

    _StepPositionService.allPositions = {
      some: function(callBack, sI) {
        callBack(sI);
      }
    };

    var stepIndicator = {
      movedStepIndex: 1
    };

    _StepMovementLeftService.ifOverLeftSide(stepIndicator);
    expect(stepIndicator.movedStepIndex).toEqual(10);
  });

  it("It should test ifOverLeftSide method, checking some method", function() {

    spyOn(_StepMovementLeftService, "ifOverLeftSideCallback").and.callFake(function(sI) {
      sI.movedStepIndex = 10;
      return true;
    });

    _StepPositionService.allPositions = {
      some: function(callBack, sI) {
        callBack(sI);
      }
    };

    var stepIndicator = {
      movedStepIndex: 1
    };

    spyOn(_StepPositionService.allPositions, "some");

    _StepMovementLeftService.ifOverLeftSide(stepIndicator);
    expect(_StepPositionService.allPositions.some).toHaveBeenCalled();
  });

  it("It should test ifOverLeftSide method, checking ifOverLeftSideCallback method", function() {

    spyOn(_StepMovementLeftService, "ifOverLeftSideCallback").and.callFake(function(sI) {
      sI.movedStepIndex = 10;
      return true;
    });

    _StepPositionService.allPositions = {
      some: function(callBack, sI) {
        callBack(sI);
      }
    };

    var stepIndicator = {
      movedStepIndex: 1
    };

    _StepMovementLeftService.ifOverLeftSide(stepIndicator);
    expect(_StepMovementLeftService.ifOverLeftSideCallback).toHaveBeenCalled();
  });

  it("It should test ifOverLeftSideCallback method", function() {

    var sI = {
      leftOffset: 20,
      currentMoveLeft: 1,
      movement: {
        left: 50
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

    _StepMovementLeftService.ifOverLeftSideCallback.apply(sI, args);

    expect(_moveStepToSides.moveToSide).toHaveBeenCalled();
    expect(_StepPositionService.getPositionObject).toHaveBeenCalled();
    expect(sI.currentMoveLeft).toEqual(0);
  });

  it("It should test ifOverLeftSideCallback method, when left is out of the boundary", function() {

    var sI = {
      leftOffset: 20,
      currentMoveLeft: 1,
      movement: {
        left: 100
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

    _StepMovementLeftService.ifOverLeftSideCallback.apply(sI, args);

    expect(sI.kanvas.allStepViews[0].moveToSide).not.toHaveBeenCalledWith("right");
    expect(_StepPositionService.getPositionObject).not.toHaveBeenCalled();
    expect(sI.currentMoveLeft).toEqual(1);
  });

  it("It should test ifOverLeftSideCallback method, when currentMoveleft is already selected", function() {

    var sI = {
      leftOffset: 20,
      currentMoveLeft: 0,
      movement: {
        left: 50
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

    _StepMovementLeftService.ifOverLeftSideCallback.apply(sI, args);

    expect(sI.kanvas.allStepViews[0].moveToSide).not.toHaveBeenCalledWith("right");
    expect(_StepPositionService.getPositionObject).not.toHaveBeenCalled();
    expect(sI.currentMoveLeft).toEqual(0);
  });

  it("It should test movedLeftAction, when step has previous step", function() {

    var sI = {
      movedStepIndex: 0,
      currentDrop: "",
      currentDropStage: "",
      kanvas: {
        allStepViews: [
          {
            previousStep: {
              parentStage: "yes"
            }
          }
        ]
      }
    };

    spyOn(_StepMovementLeftService, "manageVerticalLineLeft").and.returnValue(true);
    spyOn(_StepMovementLeftService, "manageBorderLeftForLeft").and.returnValue(true);

    _StepMovementLeftService.movedLeftAction(sI);
    expect(sI.currentDropStage).toEqual("yes");
    expect(_StepMovementLeftService.manageVerticalLineLeft).toHaveBeenCalled();
    expect(_StepMovementLeftService.manageBorderLeftForLeft).toHaveBeenCalled();

  });

  it("It should test movedLeftAction when step has no previous step", function() {

    var sI = {
      movedStepIndex: 0,
      currentDrop: "",
      currentDropStage: "",
      kanvas: {
        allStepViews: [
          {
            parentStage: "YES",

          }
        ]
      }
    };

    spyOn(_StepMovementLeftService, "manageVerticalLineLeft").and.returnValue(true);
    spyOn(_StepMovementLeftService, "manageBorderLeftForLeft").and.returnValue(true);

    _StepMovementLeftService.movedLeftAction(sI);
    expect(sI.currentDropStage).toEqual("YES");
    expect(sI.currentDrop).toEqual(null);
    expect(_StepMovementLeftService.manageVerticalLineLeft).toHaveBeenCalled();
    expect(_StepMovementLeftService.manageBorderLeftForLeft).toHaveBeenCalled();

  });

  it("It should test manageVerticalLineLeft method", function() {

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {}
      },
      movedStepIndex: 0,
      currentDrop: "",
      currentDropStage: "",
      kanvas: {
        allStepViews: [
          {
            left: 30,
            parentStage: "YES",

          }
        ]
      }
    };

    spyOn(sI.verticalLine, "setLeft");
    spyOn(sI.verticalLine, "setCoords");

    _StepMovementLeftService.manageVerticalLineLeft(sI);

    expect(sI.verticalLine.setLeft).toHaveBeenCalledWith(18);
    expect(sI.verticalLine.setCoords).toHaveBeenCalled();
  });

  it("It should test manageVerticalLineLeft method, when previousIsMoving is set", function() {

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {}
      },
      movedStepIndex: 0,
      currentDrop: "",
      currentDropStage: "",
      kanvas: {
        moveDots: {
          left: 100
        },
        allStepViews: [
          {
            previousIsMoving: true,
            left: 30,
            parentStage: "YES",

          }
        ]
      }
    };

    spyOn(sI.verticalLine, "setLeft");
    spyOn(sI.verticalLine, "setCoords");

    _StepMovementLeftService.manageVerticalLineLeft(sI);

    expect(sI.verticalLine.setLeft).toHaveBeenCalledWith(107);
    expect(sI.verticalLine.setCoords).toHaveBeenCalled();
  });

  it("It should test manageBorderLeftForLeft method", function(){

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {}
      },
      movedStepIndex: 0,
      currentDrop: "",
      currentDropStage: "",
      kanvas: {
        moveDots: {
          left: 100
        },
        allStepViews: [
          {
            previousIsMoving: true,
            left: 30,
            parentStage: "YES",
            borderLeft: {
              setVisible: function() {}
            }
          }
        ]
      }
    };

    spyOn(sI.kanvas.allStepViews[0].borderLeft, "setVisible");
    _StepMovementLeftService.manageBorderLeftForLeft(sI);
    expect(sI.kanvas.allStepViews[0].borderLeft.setVisible).toHaveBeenCalledWith(true);

  });

  it("It should test manageBorderLeftForLeft method, when the index + 1 exists ", function(){

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {}
      },
      movedStepIndex: 0,
      currentDrop: "",
      currentDropStage: "",
      kanvas: {
        moveDots: {
          left: 100
        },
        allStepViews: [
          {
            previousIsMoving: true,
            left: 30,
            parentStage: "YES",
            borderLeft: {
              setVisible: function() {}
            }
          },
          {
            previousIsMoving: true,
            left: 30,
            parentStage: "YES",
            borderLeft: {
              setVisible: function() {}
            }
          }
        ]
      }
    };

    spyOn(sI.kanvas.allStepViews[1].borderLeft, "setVisible");
    _StepMovementLeftService.manageBorderLeftForLeft(sI);
    expect(sI.kanvas.allStepViews[1].borderLeft.setVisible).toHaveBeenCalledWith(false);


  });
});
