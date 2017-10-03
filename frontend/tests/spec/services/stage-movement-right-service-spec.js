describe("Testing StageMovementRightService", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));

  beforeEach(module('canvasApp'));

  var _StageMovementRightService, _StagePositionService, _StepPositionService, _moveStageToSidesWhileMoveStep;

  beforeEach(inject(function(StageMovementRightService, StagePositionService, StepPositionService, moveStageToSidesWhileMoveStep) {

    _StageMovementRightService = StageMovementRightService;
    _StagePositionService = StagePositionService;
    _StepPositionService = StepPositionService;
    _moveStageToSidesWhileMoveStep = moveStageToSidesWhileMoveStep;
  }));

  it("It should test shouldStageMoveRight method", function() {

    sI = {
      movedStageIndex: null
    };

    spyOn(_StageMovementRightService, "shouldStageMoveRightCallback").and.callFake(function(thisObjs) {
      thisObjs.movedStageIndex = 5;
      return true;
    });

    _StagePositionService.allPositions = {

      some: function(callback, thisObjs) {
        callback(thisObjs);
      }
    };

    var rVal = _StageMovementRightService.shouldStageMoveRight(sI);
    expect(rVal).toEqual(5);
  });

  it("It should test shouldStageMoveLeft method, test shouldStageMoveRightCallback call from this method", function() {

    sI = {
      movedStageIndex: null
    };

    spyOn(_StageMovementRightService, "shouldStageMoveRightCallback").and.callFake(function(thisObjs) {
      thisObjs.movedStageIndex = 5;
      return true;
    });

    _StagePositionService.allPositions = {

      some: function(callback, thisObjs) {
        callback(thisObjs);
      }
    };

    _StageMovementRightService.shouldStageMoveRight(sI);
    expect(_StageMovementRightService.shouldStageMoveRightCallback).toHaveBeenCalled();
  });

  it("It should test shouldStageMoveLeft method, make sure 'some' method has been called", function() {

    sI = {
      movedStageIndex: null
    };

    spyOn(_StageMovementRightService, "shouldStageMoveRightCallback").and.callFake(function(thisObjs) {
      thisObjs.movedStageIndex = 5;
      return true;
    });

    _StagePositionService.allPositions = {

      some: function(callback, thisObjs) {
        callback(thisObjs);
      }
    };

    spyOn(_StagePositionService.allPositions, "some");
    _StageMovementRightService.shouldStageMoveRight(sI);
    expect(_StagePositionService.allPositions.some).toHaveBeenCalled();
  });

  it("It should test shouldStageMoveRightCallback method, when both conditions are true", function() {

    var sI = {
      movement: {
        left: 100
      },
      rightOffset: 20,
      movedRightStageIndex: 1,
      kanvas: {
        allStageViews: [
          {
            moveToSide: function() {}
          }
        ],
        allStepViews: [

        ]
      }
    };

    var args = [[200, 210, 230], 0];

    spyOn(_StagePositionService, "getPositionObject").and.returnValue(true);
    spyOn(_StagePositionService, "getAllVoidSpaces").and.returnValue(true);
    spyOn(_StepPositionService, "getPositionObject").and.returnValue(true);
    spyOn(_moveStageToSidesWhileMoveStep, "moveToSideForStep").and.returnValue();

    _StageMovementRightService.shouldStageMoveRightCallback.apply(sI, args);

    expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
    expect(_StagePositionService.getAllVoidSpaces).toHaveBeenCalled();
    expect(_StepPositionService.getPositionObject).toHaveBeenCalled();
    expect(_moveStageToSidesWhileMoveStep.moveToSideForStep).toHaveBeenCalled();
  });

  it("It should test shouldStageMoveRightCallback method, when movement.left not within the space", function() {

    var sI = {
      movement: {
        left: 1000
      },
      rightOffset: 20,
      movedRightStageIndex: 1,
      kanvas: {
        allStageViews: [
          {
            moveToSide: function() {}
          }
        ],
        allStepViews: [

        ]
      }
    };

    var args = [[200, 210, 230], 0];

    spyOn(_StagePositionService, "getPositionObject").and.returnValue(true);
    spyOn(_StagePositionService, "getAllVoidSpaces").and.returnValue(true);
    spyOn(_StepPositionService, "getPositionObject").and.returnValue(true);

    _StageMovementRightService.shouldStageMoveRightCallback.apply(sI, args);

    expect(_StagePositionService.getPositionObject).not.toHaveBeenCalled();
    expect(_StagePositionService.getAllVoidSpaces).not.toHaveBeenCalled();
    expect(_StepPositionService.getPositionObject).not.toHaveBeenCalled();
  });

  it("It should test shouldStageMoveRightCallback method, when movement.left within the space but index is already selected", function() {

    var sI = {
      movement: {
        left: 100
      },
      rightOffset: 20,
      movedRightStageIndex: 1,
      kanvas: {
        allStageViews: [
          {
            moveToSide: function() {}
          },
          {
            moveToSide: function() {}
          }
        ],
        allStepViews: [

        ]
      }
    };

    var args = [[200, 210, 230], 1];

    spyOn(_StagePositionService, "getPositionObject").and.returnValue(true);
    spyOn(_StagePositionService, "getAllVoidSpaces").and.returnValue(true);
    spyOn(_StepPositionService, "getPositionObject").and.returnValue(true);

    _StageMovementRightService.shouldStageMoveRightCallback.apply(sI, args);

    expect(_StagePositionService.getPositionObject).not.toHaveBeenCalled();
    expect(_StagePositionService.getAllVoidSpaces).not.toHaveBeenCalled();
    expect(_StepPositionService.getPositionObject).not.toHaveBeenCalled();
  });
});
