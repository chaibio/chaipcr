
describe("Testing addStageService", function() {

  var _addStageService, _constants, _correctNumberingService, _stage, _circleManager;

  beforeEach(function() {
    module('ChaiBioTech', function($provide) {
      
      mockCommonServices($provide);

      $provide.value('stage', function() {
        return {
          updateStageData: function() {},
          render: function() {}
        };
      });
    });


    inject(function($injector) {
      _addStageService = $injector.get('addStageService');
      _circleManager = $injector.get('circleManager');
      _constants = $injector.get('constants');
      _correctNumberingService = $injector.get('correctNumberingService');
      _stage = $injector.get('stage');
    });

  });


  it("It should test init method", function() {

    _addStageService.init("init");
    expect(_addStageService.canvasObj).toEqual("init");
  });

  it("It should test addNewStage method", function() {

    _addStageService.canvasObj = {
      $scope: {

      },
      allStageViews: {
        splice: function() {}
      }

    };

    var currentStage = {
      myWidth: 128,
      childSteps: [
        {
          ordealStatus: 10
        }
      ]
    };

    var data = {
      stage: {
        steps: {
          length: 2
        }
      }
    };

    spyOn(_addStageService, "makeSpaceForNewStage").and.returnValue({
      index: 1
    });

    spyOn(_addStageService, "addNextandPrevious").and.returnValue(true);
    spyOn(_addStageService, "insertStageGraphics").and.returnValue(true);

    _addStageService.addNewStage(data, currentStage, "yes");

    expect(_addStageService.makeSpaceForNewStage).toHaveBeenCalled();
    expect(_addStageService.insertStageGraphics).toHaveBeenCalled();
    expect(_addStageService.addNextandPrevious).toHaveBeenCalled();

  });

  it("It should test makeSpaceForNewStage method", function() {

    var data = {
      stage: {
        steps: [
          {
            step: 1
          },
          {
            step: 2
          }
        ]
      }
    };

    var currentStage = {
      myWidth: 0,
      moveAllStepsAndStages: function() {}
    };

    var add = 128;

    spyOn(currentStage, "moveAllStepsAndStages");

    _addStageService.makeSpaceForNewStage(data, currentStage, add);

    expect(currentStage.moveAllStepsAndStages).toHaveBeenCalled();
    expect(currentStage.myWidth).toEqual(256);
  });

  it("It should test addNextandPrevious", function() {

    var currentStage = {
      name: "currentStage",
      nextStage: {
        previousStage: {
          content: "Bin"
        }
      },
      previousStage: "yes"
    };

    var stageView = {
      name: "stageView"
    };

    _addStageService.addNextandPrevious(currentStage, stageView);
    expect(currentStage.nextStage.name).toEqual("stageView");
    expect(stageView.previousStage.name).toEqual("currentStage");
  });

  it("It should test addNextandPrevious, when currentStage is null", function() {

    var currentStage = null;

    var stageView = {
      name: "stageView"
    };

    _addStageService.canvasObj = {
      allStageViews: [
        {
          previousStage: null,
          name: "wasFirstStage"
        }
      ]
    };

    _addStageService.addNextandPrevious(currentStage, stageView);

    expect(stageView.nextStage.name).toEqual("wasFirstStage");
    expect(_addStageService.canvasObj.allStageViews[0].previousStage.name).toEqual("stageView");
  });

  it("It should test insertStageGraphics method", function() {

    _addStageService.canvasObj = {
      setDefaultWidthHeight: function() {},
      allStageViews: [
        {
          previousStage: null,
          name: "wasFirstStage",
          moveAllStepsAndStages: function() {},
        }
      ],
      $scope: {
        applyValues: function() {},
      }
    };

    var stageView = {
      stageHeader: function() {},
      childSteps: [
        {
          circle: {
            manageClick: function() {},
          }
        }
      ]
    };

    var ordealStatus = 1, mode = "insert";
    spyOn(_addStageService, "configureStepsofNewStage").and.returnValue(null);
    spyOn(_correctNumberingService, "correctNumbering").and.returnValue(true);
    spyOn(_circleManager, "addRampLines").and.returnValue(true);
    spyOn(_addStageService.canvasObj.allStageViews[0], "moveAllStepsAndStages");
    spyOn(stageView, "stageHeader");
    spyOn(_addStageService.canvasObj.$scope, "applyValues");
    spyOn(stageView.childSteps[0].circle, "manageClick");
    spyOn(_addStageService.canvasObj, "setDefaultWidthHeight");

    _addStageService.insertStageGraphics(stageView, ordealStatus, mode);

    expect(_addStageService.configureStepsofNewStage).toHaveBeenCalled();
    expect(_correctNumberingService.correctNumbering).toHaveBeenCalled();
    expect(_circleManager.addRampLines).toHaveBeenCalled();
    expect(_addStageService.canvasObj.allStageViews[0].moveAllStepsAndStages).toHaveBeenCalled();
    expect(stageView.stageHeader).toHaveBeenCalled();
    expect(_addStageService.canvasObj.$scope.applyValues).toHaveBeenCalled();
    expect(stageView.childSteps[0].circle.manageClick).toHaveBeenCalled();
    expect(_addStageService.canvasObj.setDefaultWidthHeight).toHaveBeenCalled();
  });

  it("It should test insertStageGraphics method, when mode is 'move_stage_back_to_original' ", function() {

    _addStageService.canvasObj = {
      setDefaultWidthHeight: function() {},
      allStageViews: [
        {
          previousStage: null,
          name: "wasFirstStage",
          moveAllStepsAndStages: function() {},
          getLeft: function() {},
        }
      ],
      $scope: {
        applyValues: function() {},
      }
    };

    var stageView = {
      stageHeader: function() {},
      childSteps: [
        {
          circle: {
            manageClick: function() {},
          }
        }
      ]
    };

    var ordealStatus = 1, mode = "move_stage_back_to_original";

    spyOn(_addStageService, "configureStepsofNewStage").and.returnValue(null);
    spyOn(_correctNumberingService, "correctNumbering").and.returnValue(true);
    spyOn(_circleManager, "addRampLines").and.returnValue(true);
    spyOn(_addStageService.canvasObj.allStageViews[0], "moveAllStepsAndStages");
    spyOn(_addStageService.canvasObj.allStageViews[0], "getLeft");
    spyOn(stageView, "stageHeader");
    spyOn(_addStageService.canvasObj.$scope, "applyValues");
    spyOn(stageView.childSteps[0].circle, "manageClick");
    spyOn(_addStageService.canvasObj, "setDefaultWidthHeight");

    _addStageService.insertStageGraphics(stageView, ordealStatus, mode);
    expect(_addStageService.canvasObj.allStageViews[0].getLeft).toHaveBeenCalled();
  });

  it("It should test addNewStageAtBeginning", function() {

    var data = {
      stage: {
        steps: [
          {}, {}
        ]
      }
    };

    _addStageService.canvasObj = {
      setDefaultWidthHeight: function() {},
      allStageViews: {
        splice: function() {},
      },
      $scope: {
        applyValues: function() {},
      }
    };

    spyOn(_addStageService, "addNextandPrevious").and.returnValue(true);
    spyOn(_addStageService, "insertStageGraphics").and.returnValue(true);
    spyOn(_addStageService.canvasObj.allStageViews, "splice");

    _addStageService.addNewStageAtBeginning(data);

    expect(_addStageService.addNextandPrevious).toHaveBeenCalled();
    expect(_addStageService.insertStageGraphics).toHaveBeenCalled();
    expect(_addStageService.canvasObj.allStageViews.splice).toHaveBeenCalled();

  });

  it("It should test configureStepsofNewStage", function() {

    var stageView = {
      childSteps: [
        {
          ordealStatus: 10,
          render: function() {},
          circle: {
            moveCircle: function() {},
            getCircle: function() {},
          }
        }
      ]
    };

    _addStageService.canvasObj = {
      setDefaultWidthHeight: function() {},
      allStepViews: {
        splice: function() {},
      },
      $scope: {
        applyValues: function() {},
      }
    };

    var ordealStatus =10;

    spyOn(stageView.childSteps[0], "render");
    spyOn(stageView.childSteps[0].circle, "moveCircle");
    spyOn(stageView.childSteps[0].circle, "getCircle");
    spyOn(_addStageService.canvasObj.allStepViews, "splice");

    _addStageService.configureStepsofNewStage(stageView, ordealStatus);

    expect(stageView.childSteps[0].ordealStatus).toEqual(11);
    expect(stageView.childSteps[0].render).toHaveBeenCalled();
    expect(stageView.childSteps[0].circle.moveCircle).toHaveBeenCalled();
    expect(stageView.childSteps[0].circle.getCircle).toHaveBeenCalled();
    expect(_addStageService.canvasObj.allStepViews.splice).toHaveBeenCalled();
  });
});
