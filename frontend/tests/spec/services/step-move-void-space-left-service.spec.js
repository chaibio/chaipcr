describe("Testing StepMoveVoidSpaceLeftService", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));

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

  it("It should test voidSpaceCallbackLeft method", function() {

    var sI = {
      rightOffset: 10,
      movement: {
        left: 100
      }
    };

    var arguements = [[50, 130], 1];

    spyOn(_StepMoveVoidSpaceLeftService.outerScope, "verticalLineForVoidLeft").and.returnValue(true);

    _StepMoveVoidSpaceLeftService.voidSpaceCallbackLeft.apply(sI, arguements);
    expect(_StepMoveVoidSpaceLeftService.outerScope.verticalLineForVoidLeft).toHaveBeenCalled();

  });

  it("It should test voidSpaceCallbackLeft method, when condition is not met", function() {

    var sI = {
      rightOffset: 10,
      movement: {
        left: 100
      }
    };

    var arguements = [[50, 60], 1];

    spyOn(_StepMoveVoidSpaceLeftService.outerScope, "verticalLineForVoidLeft").and.returnValue(true);

    _StepMoveVoidSpaceLeftService.voidSpaceCallbackLeft.apply(sI, arguements);
    expect(_StepMoveVoidSpaceLeftService.outerScope.verticalLineForVoidLeft).not.toHaveBeenCalled();

  });

  it("It should test verticalLineForVoidLeft method", function() {

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {}
      },
      kanvas: {
        allStageViews: [
          {
            left: 100,
            childSteps: [
              {
                step: "Yes"
              }
            ]
          }
        ]
      }
    };

    spyOn(sI.verticalLine, "setLeft");
    spyOn(sI.verticalLine, "setCoords");
    _StepMoveVoidSpaceLeftService.outerScope.verticalLineForVoidLeft(sI, 0);

    expect(sI.verticalLine.setLeft).toHaveBeenCalledWith(95);
    expect(sI.verticalLine.setCoords).toHaveBeenCalled();
  });

  it("It should test verticalLineForVoidLeft method, when step has previousIsMoving true", function() {

    var sI = {
      verticalLine: {
        setLeft: function() {},
        setCoords: function() {}
      },
      kanvas: {
        moveDots: {
          left: 50,
        },
        allStageViews: [
          {
            left: 100,
            childSteps: [
              {
                previousIsMoving: true,
                step: "Yes"
              }
            ]
          }
        ]
      }
    };

    spyOn(sI.verticalLine, "setLeft");
    spyOn(sI.verticalLine, "setCoords");
    _StepMoveVoidSpaceLeftService.outerScope.verticalLineForVoidLeft(sI, 0);

    expect(sI.verticalLine.setLeft).toHaveBeenCalledWith(57);
    expect(sI.verticalLine.setCoords).toHaveBeenCalled();
    expect(sI.currentDrop).toEqual(null);
    expect(sI.currentDropStage).toEqual(jasmine.objectContaining({
      left: 100
    }));
  });
});
