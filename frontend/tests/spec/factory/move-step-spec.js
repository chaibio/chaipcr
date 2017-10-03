describe("Testing moveStepRect", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var indicator, step, backupStageModel = {}, C = {}, _StepPositionService, _StagePositionService, footer = {left: 10},
    _StepMovementRightService, _StageMovementLeftService, _StepMoveVoidSpaceLeftService, _StepMovementLeftService,
    _StageMovementRightService, _StepMoveVoidSpaceRightService, _ExperimentLoader;

  beforeEach(inject(function(moveStepRect, Image, StepPositionService, StagePositionService, StepMovementRightService,
    StageMovementLeftService, StepMoveVoidSpaceLeftService, StepMovementLeftService, StageMovementRightService,
    StepMoveVoidSpaceRightService, ExperimentLoader, addStageService) {

    _StepPositionService = StepPositionService;
    _StagePositionService = StagePositionService;
    _StepMovementRightService = StepMovementRightService;
    _StageMovementLeftService = StageMovementLeftService;
    _StepMoveVoidSpaceLeftService = StepMoveVoidSpaceLeftService;
    _StepMovementLeftService = StepMovementLeftService;
    _StageMovementRightService = StageMovementRightService;
    _StepMoveVoidSpaceRightService = StepMoveVoidSpaceRightService;
    _ExperimentLoader = ExperimentLoader;
    _addStageService = addStageService;
    var obj = {
      imageobjects: {
        "drag-footer-image.png": Image.create()
      }
    };

    step = {
      model: {
        temperature: 80,
      },
      circle: {
        holdTime: {
          text: "1:30"
        }
      },
      numberingTextCurrent: {
        text: "numbering"
      },
      numberingTextTotal: {
        text: "numbering total"
      },
      previousStep: {

      },
      nextStep: {

      },
      parentStage: {
        stageHeader: function() {},
        adjustHeader: function() {},
        childSteps: [

        ]
      }

    };

    C = {
      canvas: {
        bringToFront: function() {}
      },
      moveDots: {
        left: 20
      }
    };

    indicator = moveStepRect.getMoveStepRect(obj);

  }));

  it("It should test indicator", function() {
    expect(indicator).toEqual(jasmine.any(Object));
  });

  it("It should test indicator.verticalLine", function() {
    expect(indicator.verticalLine).toEqual(jasmine.any(Object));
  });

  it("It should test init method [test method calls]", function() {

    spyOn(_StagePositionService, "getPositionObject");
    spyOn(_StagePositionService, "getAllVoidSpaces");
    spyOn(_StepPositionService, "getPositionObject");
    spyOn(indicator, "changeText").and.callFake(function() {
      return true;
    });

    indicator.init(step, footer, C, backupStageModel);

    expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
    expect(_StagePositionService.getAllVoidSpaces).toHaveBeenCalled();
    expect(_StepPositionService.getPositionObject).toHaveBeenCalled();
    expect(indicator.changeText).toHaveBeenCalled();
  });

  it("It should test init method [all setters]", function() {

    spyOn(indicator, "changeText").and.callFake(function() {
      return true;
    });

    indicator.init(step, footer, C, backupStageModel);
    expect(step.parentStage.sourceStage).toEqual(true);
    expect(indicator.movement).toEqual(null);
    expect(indicator.movedStepIndex).toEqual(null);
    expect(indicator.currentMoveRight).toEqual(null);
    expect(indicator.currentMoveLeft).toEqual(null);
    expect(indicator.movedStageIndex).toEqual(null);
    expect(indicator.movedRightStageIndex).toEqual(null);
    expect(indicator.movedLeftStageIndex).toEqual(null);

    expect(indicator.currentLeft).toEqual(footer.left);
    expect(indicator.rightOffset).toEqual(96);
    expect(indicator.leftOffset).toEqual(0);

  });

  it("It should test initForOneStepStage method, which is specifically handle one step stage", function() {

    spyOn(indicator, "changeText").and.callFake(function() {
      return true;
    });
    spyOn(indicator, "tagSteps").and.returnValue(true);

    indicator.initForOneStepStage(step, footer, C, backupStageModel);

    expect(indicator.changeText).not.toHaveBeenCalled();
    expect(indicator.tagSteps).not.toHaveBeenCalled();

  });
  it("It should test tagSteps method", function() {

    indicator.tagSteps(step);
    expect(step.previousStep.nextIsMoving).toEqual(true);
    expect(step.nextStep.previousIsMoving).toEqual(true);
  });

  it("It should test changeText method", function() {

    indicator.changeText(step);
    expect(indicator.temperatureText.text).toEqual(step.model.temperature + "º");
    expect(indicator.holdTimeText.text).toEqual(step.circle.holdTime.text);
    expect(indicator.indexText.text).toEqual(step.numberingTextCurrent.text);
    expect(indicator.placeText.text).toEqual(step.numberingTextCurrent.text + step.numberingTextTotal.text);
  });

  it("It should test getDirection method when moving right side", function() {

    indicator.movement = {
      left: 100
    };
    indicator.currentLeft = 99;
    indicator.direction = null;
    spyOn(indicator, "updateLocationOnMoveRight");
    indicator.getDirection();

    expect(indicator.direction).toEqual("right");
    expect(indicator.updateLocationOnMoveRight).toHaveBeenCalled();
  });

  it("It should test getDirection method when moving left side", function() {

    indicator.movement = {
      left: 100
    };
    indicator.currentLeft = 101;
    indicator.direction = null;
    spyOn(indicator, "updateLocationOnMoveLeft");
    indicator.getDirection();

    expect(indicator.direction).toEqual("left");
    expect(indicator.updateLocationOnMoveLeft).toHaveBeenCalled();
  });

  it("It should test updateLocationOnMoveRight method", function() {

    indicator.movement = {
      left: 100
    };
    var holdVal = indicator.movement.left;
    spyOn(indicator, "manageMovingRight");

    indicator.updateLocationOnMoveRight();

    expect(indicator.movement.left).toEqual(holdVal - 40);
    expect(indicator.manageMovingRight).toHaveBeenCalled();
  });

  it("It should test updateLocationOnMoveLeft method", function() {

    indicator.movement = {
      left: 100
    };
    var holdVal = indicator.movement.left;
    spyOn(indicator, "manageMovingLeft");

    indicator.updateLocationOnMoveLeft();

    expect(indicator.movement.left).toEqual(holdVal + 40);
    expect(indicator.manageMovingLeft).toHaveBeenCalled();
  });

  it("It should test manageMovingRight method", function() {

    spyOn(_StepMovementRightService, "ifOverRightSide").and.callFake(function() {
      return true;
    });


    spyOn(_StepMovementRightService, "movedRightAction");
    spyOn(_StageMovementLeftService, "shouldStageMoveLeft").and.callFake(function() {
      return true;
    });
    spyOn(_StepMoveVoidSpaceLeftService, "checkVoidSpaceLeft").and.returnValue("true");
    spyOn(indicator, "hideFirstStepBorderLeft").and.returnValue(true);
    indicator.manageMovingRight();

    expect(_StepMovementRightService.ifOverRightSide).toHaveBeenCalled();
    expect(_StepMovementRightService.movedRightAction).toHaveBeenCalled();
    expect(_StepMoveVoidSpaceLeftService.checkVoidSpaceLeft).toHaveBeenCalled();
    expect(indicator.hideFirstStepBorderLeft).toHaveBeenCalled();
  });

  it("It should test manageMovingRight method [ when the methods return null ]", function() {

    spyOn(_StepMovementRightService, "ifOverRightSide").and.callFake(function() {
      return null;
    });


    spyOn(_StepMovementRightService, "movedRightAction");
    spyOn(_StageMovementLeftService, "shouldStageMoveLeft").and.callFake(function() {
      return null;
    });
    spyOn(_StepMoveVoidSpaceLeftService, "checkVoidSpaceLeft").and.returnValue("true");
    spyOn(indicator, "hideFirstStepBorderLeft").and.returnValue(true);
    indicator.manageMovingRight();

    expect(_StepMovementRightService.ifOverRightSide).toHaveBeenCalled();
    expect(_StepMovementRightService.movedRightAction).not.toHaveBeenCalled();

    expect(_StageMovementLeftService.shouldStageMoveLeft).toHaveBeenCalled();

    expect(_StepMoveVoidSpaceLeftService.checkVoidSpaceLeft).toHaveBeenCalled();
    expect(indicator.hideFirstStepBorderLeft).not.toHaveBeenCalled();
  });

  it("It should test manageMovingLeft method", function() {

    spyOn(_StepMovementLeftService, "ifOverLeftSide").and.callFake(function() {
      return true;
    });

    spyOn(_StepMovementLeftService, "movedLeftAction");

    spyOn(_StageMovementRightService, "shouldStageMoveRight").and.callFake(function() {
      return true;
    });

    spyOn(_StepMoveVoidSpaceRightService, "checkVoidSpaceRight").and.returnValue("true");

    spyOn(indicator, "hideFirstStepBorderLeft").and.returnValue(true);

    indicator.manageMovingLeft();

    expect(_StepMovementLeftService.ifOverLeftSide).toHaveBeenCalled();
    expect(_StepMovementLeftService.movedLeftAction).toHaveBeenCalled();

    expect(_StageMovementRightService.shouldStageMoveRight).toHaveBeenCalled();
    expect(_StepMoveVoidSpaceRightService.checkVoidSpaceRight).toHaveBeenCalled();
    expect(indicator.hideFirstStepBorderLeft).toHaveBeenCalled();
  });

  it("It should test manageMovingLeft method [ when methods return null ]", function() {

    spyOn(_StepMovementLeftService, "ifOverLeftSide").and.callFake(function() {
      return null;
    });

    spyOn(_StepMovementLeftService, "movedLeftAction");

    spyOn(_StageMovementRightService, "shouldStageMoveRight").and.callFake(function() {
      return null;
    });

    spyOn(_StepMoveVoidSpaceRightService, "checkVoidSpaceRight").and.returnValue("true");

    spyOn(indicator, "hideFirstStepBorderLeft").and.returnValue(true);

    indicator.manageMovingLeft();

    expect(_StepMovementLeftService.ifOverLeftSide).toHaveBeenCalled();
    expect(_StepMovementLeftService.movedLeftAction).not.toHaveBeenCalled();

    expect(_StageMovementRightService.shouldStageMoveRight).toHaveBeenCalled();
    expect(_StepMoveVoidSpaceRightService.checkVoidSpaceRight).toHaveBeenCalled();
    expect(indicator.hideFirstStepBorderLeft).not.toHaveBeenCalled();
  });

  it("It should test onTheMove method when moving RIGHT", function() {

    spyOn(indicator, "setLeft");
    spyOn(indicator, "getDirection").and.returnValue("right");
    spyOn(indicator, "manageMovingRight");
    spyOn(indicator, "manageMovingLeft");
    var movement = {
      left: 20
    };

    indicator.onTheMove(movement);

    expect(indicator.setLeft).toHaveBeenCalled();
    expect(indicator.getDirection).toHaveBeenCalled();
    expect(indicator.manageMovingRight).toHaveBeenCalled();
    expect(indicator.manageMovingLeft).not.toHaveBeenCalled();
  });

  it("It should test onTheMove method when moving LEFT", function() {

    spyOn(indicator, "setLeft");
    spyOn(indicator, "getDirection").and.returnValue("left");
    spyOn(indicator, "manageMovingRight");
    spyOn(indicator, "manageMovingLeft");
    var movement = {
      left: 20
    };

    indicator.onTheMove(movement);

    expect(indicator.setLeft).toHaveBeenCalled();
    expect(indicator.getDirection).toHaveBeenCalled();
    expect(indicator.manageMovingRight).not.toHaveBeenCalled();
    expect(indicator.manageMovingLeft).toHaveBeenCalled();

  });

  it("It should test hideFirstStepBorderLeft method", function() {
    indicator.movedStageIndex = 0;
    indicator.kanvas = {
      allStageViews: [
        {
          childSteps: [
            {
              borderLeft: {
                setVisible: function() {}
              }
            }
          ]
        },
      ]
    };
    var bLeft = indicator.kanvas.allStageViews[0].childSteps[0].borderLeft;

    spyOn(bLeft, "setVisible");
    indicator.hideFirstStepBorderLeft();
    expect(bLeft.setVisible).toHaveBeenCalled();

  });

  it("It should test manageSingleStepStage method , [when childStep length !== 0]", function() {

    var step = {
      parentStage: {
        childSteps: [
          {},
          {}
        ]
      }
    };

    var manageSingleStepStageReturnVal = indicator.manageSingleStepStage(step);
    expect(manageSingleStepStageReturnVal).toEqual(false); // Because length of childSteps !== 0
  });

  it("It should test manageSingleStepStage method , [when childStep length === 0]", function() {

    var step = {
      parentStage: {
        deleteStageContents: function() {},
        childSteps: [

        ]
      }
    };
    spyOn(step.parentStage, "deleteStageContents");
    var manageSingleStepStageReturnVal = indicator.manageSingleStepStage(step);
    expect(step.parentStage.deleteStageContents).toHaveBeenCalled();
    expect(manageSingleStepStageReturnVal).toEqual(false); // Because length of childSteps !== 0
  });

  it("It should test processMovement method, [when manageSingleStepStage method returns true]", function() {

    spyOn(indicator.verticalLine, "setVisible");
    spyOn(indicator, "manageSingleStepStage").and.returnValue(true);
    var step = {
      parentStage: {
        childSteps: [
          {},
          {},
        ],
        addNewStage: function() {},
        addNewStepAtTheBeginning: function() {}
      },

    };

    var p = indicator.processMovement(step, C);
    expect(indicator.verticalLine.setVisible).toHaveBeenCalled();
    expect(p).toEqual(true);
  });

  it("It should test processMovement method, [when manageSingleStepStage method returns false and when targetStep is not null]", function() {

    spyOn(indicator.verticalLine, "setVisible");
    spyOn(indicator, "manageSingleStepStage").and.returnValue(false);
    spyOn(_ExperimentLoader, "moveStep").and.callFake(function() {
      return {
        then: function(successCallback, failureCallback) {
          if(typeof(successCallback) === 'function') {
            successCallback();
          }
          if(typeof(failureCallback) === 'function') {
            failureCallback();
          }

        }
      };
    });

    indicator.kanvas = {
      allStageViews: [
        {
          moveAllStepsAndStages: function() {}
        }
      ]
    };
    var step = {
      left: 10,
      parentStage: {
        childSteps: [
          {},
          {},
        ],
        addNewStep: function() {},
        addNewStepAtTheBeginning: function() {},
        model: {
          id: 10
        },
      },
      model: {

      }
    };
    indicator.currentDrop = step;
    indicator.currentDropStage = step.parentStage;

    indicator.processMovement(step, C);
    expect(indicator.verticalLine.setVisible).toHaveBeenCalled();
    expect(step.parentStage.sourceStage).toEqual(false);
    expect(_ExperimentLoader.moveStep).toHaveBeenCalled();
  });

  it("It should test processMovement method, [when manageSingleStepStage method returns false and when targetStep is null]", function() {

    spyOn(indicator.verticalLine, "setVisible");
    spyOn(indicator, "manageSingleStepStage").and.returnValue(false);
    spyOn(_ExperimentLoader, "moveStep").and.callFake(function() {
      return {
        then: function(successCallback, failureCallback) {
          if(typeof(successCallback) === 'function') {
            successCallback();
          }
          if(typeof(failureCallback) === 'function') {
            failureCallback();
          }

        }
      };
    });
    indicator.kanvas = {
      allStageViews: [
        {
          moveAllStepsAndStages: function() {}
        }
      ]
    };
    var step = {
      left: 10,
      parentStage: {
        childSteps: [
          {},
          {},
        ],
        addNewStep: function() {},
        addNewStepAtTheBeginning: function() {},
        model: {
          id: 10
        },
      },
      model: {

      }
    };

    indicator.currentDrop = null;
    indicator.currentDropStage = step.parentStage;

    indicator.processMovement(step, C);
    expect(indicator.verticalLine.setVisible).toHaveBeenCalled();
    expect(step.parentStage.sourceStage).toEqual(false);
    expect(_ExperimentLoader.moveStep).toHaveBeenCalled();
  });

  it("It should test manageSingleStepStage method when currentDrop === NOTHING and has previousStage", function() {

    var step = {
      parentStage: {
        deleteStageContents: function() {},
        childSteps: {
          length: 0
        },
        previousStage: {

        }
      }
    };

    indicator.currentDrop = "NOTHING";
    spyOn(_addStageService, "addNewStage").and.returnValue(true);
    spyOn(step.parentStage, "deleteStageContents");

    indicator.manageSingleStepStage(step);

    expect(step.parentStage.deleteStageContents).toHaveBeenCalled();
    expect(_addStageService.addNewStage).toHaveBeenCalled();

  });

  it("It should test manageSingleStepStage method when currentDrop === NOTHING and has no previousStage", function() {

    var step = {
      parentStage: {
        deleteStageContents: function() {},
        childSteps: {
          length: 0
        },

      }
    };

    indicator.currentDrop = "NOTHING";
    spyOn(_addStageService, "addNewStageAtBeginning").and.returnValue(true);
    spyOn(step.parentStage, "deleteStageContents");

    indicator.manageSingleStepStage(step);

    expect(step.parentStage.deleteStageContents).toHaveBeenCalled();
    expect(_addStageService.addNewStageAtBeginning).toHaveBeenCalled();

  });
});
