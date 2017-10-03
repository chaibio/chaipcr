describe("Testing StepMoveVoidSpaceRightService", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));

  var _StepMoveVoidSpaceRightService, _StagePositionService;

  beforeEach(inject(function(StepMoveVoidSpaceRightService, StagePositionService) {
    _StepMoveVoidSpaceRightService = StepMoveVoidSpaceRightService;
    _StagePositionService = StagePositionService;
  }));

  it("It should test checkVoidSpaceRight", function() {
    console.log("bing", _StepMoveVoidSpaceRightService.outerScope);
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

  it("It should test checkVoidSpaceRight and make sure voidSpaceCallbackRight has been called", function() {

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

  it("It should test voidSpaceCallbackRight method when conditions met", function() {

    var sI = {
      movement: {
        left: 40,
      },
    };
    var arguements = [[25, 75], 0];
    spyOn(_StepMoveVoidSpaceRightService.outerScope, "verticalLineForVoidRight").and.returnValue(true);

    _StepMoveVoidSpaceRightService.voidSpaceCallbackRight.apply(sI, arguements);
    expect(_StepMoveVoidSpaceRightService.outerScope.verticalLineForVoidRight).toHaveBeenCalled();

  });

  it("It should test voidSpaceCallbackRight method when conditions not met", function() {

    var sI = {
      movement: {
        left: 100,
      },
    };
    var arguements = [[25, 75], 0];
    spyOn(_StepMoveVoidSpaceRightService.outerScope, "verticalLineForVoidRight").and.returnValue(true);

    _StepMoveVoidSpaceRightService.voidSpaceCallbackRight.apply(sI, arguements);
    expect(_StepMoveVoidSpaceRightService.outerScope.verticalLineForVoidRight).not.toHaveBeenCalled();

  });

  it("It should test verticalLineForVoidRight method", function() {

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {},
      },
      kanvas: {
        allStageViews: [
          {
            left: 100,
            myWidth: 50,
            childSteps: [
              {
                stepNo: 1
              }
            ]
          }
        ]
      }
    };

    spyOn(sI.verticalLine, "setLeft");
    spyOn(sI.verticalLine, "setCoords");

    _StepMoveVoidSpaceRightService.outerScope.verticalLineForVoidRight(sI, 1);

    expect(sI.verticalLine.setLeft).toHaveBeenCalledWith(145);
    expect(sI.verticalLine.setCoords).toHaveBeenCalled();

  });

  it("It should test verticalLineForVoidRight method, when allStageViews[index - 1] doesn't exist ", function() {

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {},
      },
      kanvas: {
        allStageViews: [
          {
            left: 100,
            myWidth: 50,
            childSteps: [
              {
                stepNo: 1
              }
            ]
          }
        ]
      }
    };

    spyOn(sI.verticalLine, "setLeft");
    spyOn(sI.verticalLine, "setCoords");

    _StepMoveVoidSpaceRightService.outerScope.verticalLineForVoidRight(sI, 3);

    expect(sI.verticalLine.setLeft).not.toHaveBeenCalled();
    expect(sI.verticalLine.setCoords).not.toHaveBeenCalled();

  });

  it("It should test verticalLineForVoidRight method, nextIsMoving is true ", function() {

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {},
      },
      kanvas: {
        moveDots: {
          left: 100
        },
        allStageViews: [
          {
            left: 100,
            myWidth: 50,
            childSteps: [
              {
                stepNo: 1,
                nextIsMoving: true,
              }
            ]
          }
        ]
      }
    };

    spyOn(sI.verticalLine, "setLeft");
    spyOn(sI.verticalLine, "setCoords");

    _StepMoveVoidSpaceRightService.outerScope.verticalLineForVoidRight(sI, 1);

    expect(sI.verticalLine.setLeft).toHaveBeenCalledWith(107);
    expect(sI.verticalLine.setCoords).toHaveBeenCalled();

  });

  it("It should test verticalLineForVoidRight method, check currentDrop and currentDropStage", function() {

    var sI = {

      verticalLine: {
        setLeft: function() {},
        setCoords: function() {},
      },

      kanvas: {
        moveDots: {
          left: 100
        },
        allStageViews: [
          {
            testParent: "Yes",
            left: 100,
            myWidth: 50,
            childSteps: [
              {
                testMember: "Yes",
                stepNo: 1,
                nextIsMoving: true,
              }
            ]
          }
        ]
      }
    };

    spyOn(sI.verticalLine, "setLeft");
    spyOn(sI.verticalLine, "setCoords");

    _StepMoveVoidSpaceRightService.outerScope.verticalLineForVoidRight(sI, 1);

    expect(sI.currentDrop).toEqual(jasmine.objectContaining({
      testMember: "Yes",
    }));

    expect(sI.currentDropStage).toEqual(jasmine.objectContaining({
      testParent: "Yes",
    }));
  });
});
