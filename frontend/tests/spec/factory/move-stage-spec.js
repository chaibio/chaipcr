describe("Testing move-stage", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));

  beforeEach(module('canvasApp'));

  var _moveStageRect, indicator, stage = {}, C, movement = {}, _StagePositionService, _ExperimentLoader, _correctNumberingService;

  C = {
    canvas: {
      bringToFront: function() {},
      allStageViews: [
        {
          childSteps: [
            {
              step: "first"
            }
          ]
        }

      ]
    }
  };

  stage = {
    left: 150,
    moveToSide: function() {

    }
  };

  movement = {
    left: 100
  };

  beforeEach(inject(function(moveStageRect, StagePositionService, ExperimentLoader, correctNumberingService, moveStageToSides ,
    addStageService) {
    var me = {};
    indicator = moveStageRect.getMoveStageRect(me);
    _StagePositionService = StagePositionService;
    _ExperimentLoader = ExperimentLoader;
    _correctNumberingService = correctNumberingService;
    _moveStageToSides = moveStageToSides;
    _addStageService = addStageService;
  }));

  it("It should check if indicator exists", function() {
    expect(indicator).toEqual(jasmine.any(Object));
  });

  it("It should check if indicator exists", function() {
    expect(indicator.verticalLine).toEqual(jasmine.any(Object));
  });

  it("It should check if canvasContaining exists", function() {
    expect(indicator.canvasContaining).toEqual(jasmine.any(Object));
  });

  it("It should check init method, check set values", function() {
    indicator.init(stage, C, movement);
    expect(indicator.rightOffset).toEqual(85);
    expect(indicator.leftOffset).toEqual(-55);
    expect(indicator.currentLeft).toEqual(movement.left);
    expect(indicator.currentMoveRight).toEqual(null);
    expect(indicator.currentMoveLeft).toEqual(null);
    expect(indicator.currentDrop).toEqual(null);
    expect(indicator.direction).toEqual(null);
    expect(indicator.draggedStage).toEqual(stage);
    expect(indicator.currentMoveRight).toEqual(null);

  });

  it("it should check init method, function calls ", function() {
    spyOn(indicator, "setLeft");
    spyOn(indicator, "setVisible");
    spyOn(indicator, "setCoords");

    indicator.verticalLine = {
      setVisible: function() {},
      setLeft: function() {},
      setCoords: function() {}
    };

    spyOn(indicator.verticalLine, "setLeft");
    spyOn(indicator.verticalLine, "setVisible");
    spyOn(indicator.verticalLine, "setCoords");

    spyOn(_StagePositionService, "getPositionObject");
    indicator.init(stage, C, movement);

    expect(indicator.setCoords).toHaveBeenCalled();
    expect(indicator.setLeft).toHaveBeenCalled();
    expect(indicator.setVisible).toHaveBeenCalled();

    expect(indicator.verticalLine.setLeft).toHaveBeenCalled();
    expect(indicator.verticalLine.setVisible).toHaveBeenCalled();
    expect(indicator.verticalLine.setCoords).toHaveBeenCalled();
    expect(_StagePositionService.getPositionObject).toHaveBeenCalled();

  });

  it("It should check init when a passed stage has previousStage", function() {
    stage.previousStage = "previousStage";
    indicator.init(stage, C, movement);
    expect(indicator.currentDrop).toEqual("previousStage");
  });

  it("It should check changeText method", function() {
    indicator.init(stage, C, movement);
    stage.stageCaption = {
      text: "stageCaption"
    };
    stage.model = {
      stage_type: "Holding"
    };

    indicator.changeText(stage);

    expect(indicator.stageName.text).toEqual("stageCaption");
    expect(indicator.stageType.text).toEqual("HOLDING");

  });

  it("It should check getDirection method, when we move right", function() {
    indicator.init(stage, C, movement);
    movement.left = 110;
    indicator.getDirection();
    expect(indicator.direction).toEqual("right");

  });

  it("It should check getDirection method, when we move left", function() {
    indicator.init(stage, C, movement);
    movement.left = 90;
    indicator.currentLeft = 100;
    indicator.direction = "right";
    indicator.getDirection();
    expect(indicator.direction).toEqual("left");

  });

  it("It should test ifOverRightSideForOneStepStage method, this is invoked when we user drag stage over a single step stage", function() {
    movement = {
      left: 250,
    };
    indicator.init(stage, C, movement);
    _StagePositionService.allPositions = [
      [33, 162, 291]
    ];

    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];
    spyOn(indicator, "ifOverRightSideForOneStepStageCallback");
    indicator.ifOverRightSideForOneStepStage();
    expect(indicator.ifOverRightSideForOneStepStageCallback).toHaveBeenCalled();
  });

  it("It should test ifOverRightSideForOneStepStageCallback", function() {

    movement = {
      left: 250,
    };
    indicator.init(stage, C, movement);
    spyOn(_StagePositionService, "getPositionObject");

    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];

    spyOn(_moveStageToSides, "moveToSide");
    indicator.ifOverRightSideForOneStepStageCallback([33, 162, 291], 0);

    expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
    expect(_moveStageToSides.moveToSide).toHaveBeenCalled();
    expect(indicator.currentMoveRight).toEqual(0);
  });

  it("It should test ifOverLeftSideForOneStepStage method", function() {

    movement = {
      left: 100,
    };
    indicator.init(stage, C, movement);
    _StagePositionService.allPositions = [
      [33, 200, 291]
    ];

    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];

    spyOn(indicator, "ifOverLeftSideForOneStepStageCallback");
    indicator.ifOverLeftSideForOneStepStage();
    expect(indicator.ifOverLeftSideForOneStepStageCallback).toHaveBeenCalled();
  });

  it("It should test ifOverLeftSideForOneStepStageCallback method", function() {

    movement = {
      left: 100,
    };

    indicator.init(stage, C, movement);

    spyOn(_StagePositionService, "getPositionObject");

    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];

    spyOn(_moveStageToSides, "moveToSide");
    indicator.ifOverLeftSideForOneStepStageCallback([33, 200, 291], 0);

    expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
    expect(_moveStageToSides.moveToSide).toHaveBeenCalled();
    expect(indicator.movedStageIndex).toEqual(0);
  });

  it("It should test ifOverRightSide method", function() {

    movement = {
      left: 250,
    };
    indicator.init(stage, C, movement);
    _StagePositionService.allPositions = [
      [33, 162, 291]
    ];

    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];
    spyOn(indicator, "ifOverRightSideCallback");
    indicator.ifOverRightSide();
    expect(indicator.ifOverRightSideCallback).toHaveBeenCalled();
    expect(indicator.movedStageIndex).toEqual(null);
  });

  it("It should test ifOverRightSideCallback method", function() {

    movement = {
      left: 200,
    };
    indicator.init(stage, C, movement);
    spyOn(_StagePositionService, "getPositionObject");

    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];

    spyOn(_moveStageToSides, "moveToSide");
    indicator.ifOverRightSideCallback([33, 100, 291], 0);

    expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
    expect(_moveStageToSides.moveToSide).toHaveBeenCalled();
    expect(indicator.currentMoveRight).toEqual(0);

  });

  it("It should test ifOverLeftSide method", function() {

    movement = {
      left: 250,
    };
    indicator.init(stage, C, movement);
    _StagePositionService.allPositions = [
      [33, 162, 291]
    ];

    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];
    spyOn(indicator, "ifOverLeftSideCallback");
    indicator.ifOverLeftSide();
    expect(indicator.ifOverLeftSideCallback).toHaveBeenCalled();
    expect(indicator.movedStageIndex).toEqual(null);
  });

  it("It should test ifOverLeftSideCallback method", function() {

    movement = {
      left: 100,
    };
    indicator.init(stage, C, movement);
    spyOn(_StagePositionService, "getPositionObject");

    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];

    spyOn(_moveStageToSides, "moveToSide");
    indicator.ifOverLeftSideCallback([33, 200, 291], 0);

    expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
    expect(_moveStageToSides.moveToSide).toHaveBeenCalled();
    expect(indicator.currentMoveLeft).toEqual(0);

  });

  it("It should test movedRightAction method", function() {

    spyOn(indicator, "manageVerticalLineRight");
    indicator.init(stage, C, movement);
    this.movedStageIndex = 0;
    indicator.movedRightAction();
    //expect(indicator.currentMoveLeft).toEqual(null);
    expect(indicator.manageVerticalLineRight).toHaveBeenCalled();
  });

  it("It should test movedLeftAction method", function() {

    spyOn(indicator, "manageVerticalLineLeft");
    indicator.init(stage, C, movement);
    this.movedStageIndex = 1;
    indicator.movedLeftAction();
    //expect(indicator.currentMoveRight).toEqual(null);
    expect(indicator.manageVerticalLineLeft).toHaveBeenCalled();
  });

  it("It should test onTheMove method when moving direction is right ifOverRightSide() !== null", function() {

    indicator.init(stage, C, movement);

    spyOn(indicator, "checkMovingOffScreen");
    spyOn(indicator, "getDirection").and.returnValue("right");
    spyOn(indicator, "ifOverRightSide").and.returnValue(1);
    spyOn(indicator, "movedRightAction");
    indicator.onTheMove({left: 50});

    expect(indicator.checkMovingOffScreen).toHaveBeenCalled();
    expect(indicator.ifOverRightSide).toHaveBeenCalled();
    expect(indicator.movedRightAction).toHaveBeenCalled();
  });

  it("It should test onTheMove method when moving direction is right ifOverRightSide() === null", function() {

    indicator.init(stage, C, movement);

    spyOn(indicator, "checkMovingOffScreen");
    spyOn(indicator, "getDirection").and.returnValue("right");
    spyOn(indicator, "ifOverRightSide").and.returnValue(null);
    spyOn(indicator, "ifOverRightSideForOneStepStage").and.returnValue(1);
    spyOn(indicator, "movedRightAction");
    indicator.onTheMove({left: 50});

    expect(indicator.checkMovingOffScreen).toHaveBeenCalled();
    expect(indicator.ifOverRightSide).toHaveBeenCalled();
    expect(indicator.movedRightAction).toHaveBeenCalled();
  });

  it("It should test onTheMove method when moving direction is left ifOverLeftSide() !== null", function() {

    indicator.init(stage, C, movement);

    spyOn(indicator, "checkMovingOffScreen");
    spyOn(indicator, "getDirection").and.returnValue("left");
    spyOn(indicator, "ifOverLeftSide").and.returnValue(1);
    spyOn(indicator, "movedLeftAction");
    indicator.onTheMove({left: 150});

    expect(indicator.checkMovingOffScreen).toHaveBeenCalled();
    expect(indicator.ifOverLeftSide).toHaveBeenCalled();
    expect(indicator.movedLeftAction).toHaveBeenCalled();
  });

  it("It should test onTheMove method when moving direction is left ifOverLeftSide() === null", function() {

    indicator.init(stage, C, movement);

    spyOn(indicator, "checkMovingOffScreen");
    spyOn(indicator, "getDirection").and.returnValue("left");
    spyOn(indicator, "ifOverLeftSide").and.returnValue(null);
    spyOn(indicator, "ifOverLeftSideForOneStepStage").and.returnValue(1);
    spyOn(indicator, "movedLeftAction");
    indicator.onTheMove({left: 150});

    expect(indicator.checkMovingOffScreen).toHaveBeenCalled();
    expect(indicator.ifOverLeftSide).toHaveBeenCalled();
    expect(indicator.movedLeftAction).toHaveBeenCalled();
  });

  it("It should test checkMovingOffScreen method with right parameter passed", function() {

    indicator.init(stage, C, movement);
    spyOn(indicator.canvasContaining, "scrollLeft").and.returnValue(100);
    indicator.movement.left = 1000;
    indicator.checkMovingOffScreen("right");
    expect(indicator.canvasContaining.scrollLeft).toHaveBeenCalledWith(indicator.movement.left - 889);
  });

  it("It should test checkMovingOffscreen method with left parameter passed", function() {
    indicator.init(stage, C, movement);
    spyOn(indicator.canvasContaining, "scrollLeft").and.returnValue(1800);
    indicator.movement.left = 1000;
    indicator.checkMovingOffScreen("left");
    expect(indicator.canvasContaining.scrollLeft).toHaveBeenCalledWith(indicator.canvasContaining.scrollLeft() - (indicator.canvasContaining.scrollLeft() - indicator.movement.left));
  });

  it("It should test manageVerticalLineRight method", function() {

    indicator.init(stage, C, movement);
    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        left: 150,
        myWidth: 120,
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];


    spyOn(indicator.verticalLine, "setLeft");
    spyOn(indicator.verticalLine, "setCoords");
    indicator.manageVerticalLineRight(0);
    expect(indicator.verticalLine.setLeft).toHaveBeenCalledWith(283);
    expect(indicator.verticalLine.setCoords).toHaveBeenCalled();
  });

  it("It should test manageVerticalLineLeft method", function() {

    indicator.init(stage, C, movement);
    indicator.kanvas.allStageViews = [
      {
        moveToSide: function() {},
        left: 150,
        myWidth: 120,
        childSteps: [
          {
            step: "first"
          }
        ]

      },
    ];


    spyOn(indicator.verticalLine, "setLeft");
    indicator.manageVerticalLineLeft(0);
    expect(indicator.verticalLine.setLeft).toHaveBeenCalledWith(125);
  });


  it("It should test processMovement method", function() {

    indicator.init(stage, C, movement);

    spyOn(_ExperimentLoader, "moveStage").and.returnValue({
      then: function(successCallback, errorCallback) {
        successCallback();
        errorCallback();
      }
    });
    spyOn(indicator.verticalLine, "getVisible").and.returnValue(true);
    spyOn(indicator, "applyMovement");
    spyOn(indicator, "hideElements");

    indicator.currentDrop = {
      model: {
        id: 10
      }
    };

    indicator.processMovement(stage, "circleManager");

    expect(indicator.applyMovement).toHaveBeenCalled();
    expect(indicator.hideElements).toHaveBeenCalled();
    expect(_ExperimentLoader.moveStage).toHaveBeenCalled();
  });

  it("It should check hideElements method", function() {

    indicator.init(stage, C, movement);
    spyOn(indicator, "setVisible");
    spyOn(indicator.verticalLine, "setVisible");

    indicator.hideElements();

    expect(indicator.setVisible).toHaveBeenCalled();
    expect(indicator.direction).toEqual(null);
    expect(indicator.verticalLine.setVisible).toHaveBeenCalled();
  });

  it("It should check applyMovement method when, method has currentDrop value", function() {

    indicator.init(stage, C, movement);

    indicator.draggedStage = {
      model: {
        name: "Jossie",
        steps: [
          {
          }
        ],
      }
    };
    indicator.currentDrop = {
      index: 1
    };

    indicator.kanvas = {
      addNextandPrevious: function() {},
      canvas: {
        remove: function() {},
        add: function() {}
      },
      allStepViews: [],
      allStageViews: [],
      $scope: {}
    };

    var _stage = {
      dots: []
    };

    spyOn(_addStageService, "addNewStage").and.returnValue(true);
    indicator.applyMovement(_stage, {});
    expect(_addStageService.addNewStage).toHaveBeenCalled();
  });

  it("It should check applyMovement method, when method has no currentDrop value", function() {

    indicator.init(stage, C, movement);

    indicator.draggedStage = {
      model: {
        name: "Jossie",
        steps: [
          {
          }
        ],
      }
    };
    indicator.currentDrop = null;

    indicator.kanvas = {
      addNextandPrevious: function() {},
      canvas: {
        remove: function() {},
        add: function() {}
      },
      allStepViews: [],
      allStageViews: [],
      $scope: {}
    };

    var _stage = {
      dots: []
    };

    spyOn(_addStageService, "addNewStageAtBeginning").and.returnValue(true);
    indicator.applyMovement(_stage, {});
    expect(_addStageService.addNewStageAtBeginning).toHaveBeenCalled();
  });

});

