describe("Testing add-step-service", function() {

  var _addStepService, _constants, _correctNumberingService, _step, _circleManager;
  beforeEach(function() {

    module('ChaiBioTech', function($provide) {

      mockCommonServices($provide);

      $provide.value('step', function() {
        return {
          render: function() {}
        };
      });

    });

    inject(function($injector) {
      _addStepService = $injector.get('addStepService');
      _circleManager = $injector.get('circleManager');
      _constants = $injector.get('constants');
      _correctNumberingService = $injector.get("correctNumberingService");
      _step = $injector.get("step");
    });
  });

  it("It should test addNewStep method", function() {

    var stage = {
      setNewWidth: function() {},
      moveAllStepsAndStages: function() {},
      parent: {
        allStepViews: {
          splice: function() {},
        }
      },
      childSteps: [
        {
          ordealStatus: 1
        },
      ],
      model: {
        steps: {
          splice: function() {}
        }
      }
    };

    var stepData = {
      step: {

      }
    };

    var currentStep = {
      index: 1,
      ordealStatus: 2
    };

    var $scope = {

    };

    spyOn(stage, 'setNewWidth');
    spyOn(stage, 'moveAllStepsAndStages');
    spyOn(stage.childSteps, "splice");
    spyOn(stage.model.steps, "splice");
    spyOn(stage.parent.allStepViews, "splice");

    spyOn(_addStepService, "configureStep").and.returnValue(true);
    spyOn(_addStepService, "postAddStep").and.returnValue(true);

    _addStepService.addNewStep(stage, stepData, currentStep, $scope);

    expect(stage.setNewWidth).toHaveBeenCalled();
    expect(stage.moveAllStepsAndStages).toHaveBeenCalled();
    expect(stage.childSteps.splice).toHaveBeenCalled();
    expect(stage.model.steps.splice).toHaveBeenCalled();
    expect(stage.parent.allStepViews.splice).toHaveBeenCalled();
    expect(_addStepService.configureStep).toHaveBeenCalled();
    expect(_addStepService.postAddStep).toHaveBeenCalled();
  });

  it("It should test addNewStep method when currentStep = null", function() {

    var stage = {
      setNewWidth: function() {},
      moveAllStepsAndStages: function() {},
      parent: {
        allStepViews: {
          splice: function() {},
        }
      },
      childSteps: [
        {
          ordealStatus: 1
        },
      ],
      model: {
        steps: {
          splice: function() {}
        }
      }
    };

    var stepData = {
      step: {

      }
    };

    var currentStep = false;

    var $scope = {

    };

    spyOn(stage, 'setNewWidth');
    spyOn(stage, 'moveAllStepsAndStages');
    spyOn(stage.childSteps, "splice");
    spyOn(stage.model.steps, "splice");
    spyOn(stage.parent.allStepViews, "splice");

    spyOn(_addStepService, "configureStep").and.returnValue(true);
    spyOn(_addStepService, "postAddStep").and.returnValue(true);

    _addStepService.addNewStep(stage, stepData, currentStep, $scope);

    expect(stage.childSteps.splice).toHaveBeenCalledWith(0, 0, jasmine.any(Object));

  });

  it("It should test configureStep method", function() {

    var stage = {
      setNewWidth: function() {},
      moveAllStepsAndStages: function() {},
      parent: {
        allStepViews: {
          splice: function() {},
        }
      },
      childSteps: [
        {
          ordealStatus: 1,
          index: 10,
          configureStepName: function() {},
          moveStep: function() {},
          numberingValue: function() {},
        },
        {
          ordealStatus: 1,
          index: 11,
          configureStepName: function() {},
          moveStep: function() {},
          numberingValue: function() {},
        },
        {
          ordealStatus: 1,
          index: 12,
          configureStepName: function() {},
          moveStep: function() {},
          numberingValue: function() {},
        },
      ],
      model: {
        steps: {
          splice: function() {}
        }
      }
    };

    var newStep = {
      index: 1,
      nextStep: {

      },
      previousStep: function() {

      }
    };

    var start = 0;

    spyOn(stage.childSteps[1], 'configureStepName');
    spyOn(stage.childSteps[1], 'moveStep');

    spyOn(stage.childSteps[0], 'numberingValue');

    spyOn(stage.childSteps[2], 'configureStepName');
    spyOn(stage.childSteps[2], 'moveStep');
    _addStepService.configureStep(stage, newStep, start);

    expect(stage.childSteps[1].configureStepName).toHaveBeenCalled();
    expect(stage.childSteps[1].moveStep).toHaveBeenCalled();

    expect(stage.childSteps[2].configureStepName).toHaveBeenCalled();
    expect(stage.childSteps[2].moveStep).toHaveBeenCalled();

    expect(stage.childSteps[0].numberingValue).toHaveBeenCalled();

    expect(newStep.nextStep.index).toEqual(13);
    expect(newStep.previousStep.index).toEqual(10);
  });

  it("It should test configureStep method when we supply a stage with no childSteps, newStep should not add next/previous steps", function() {

    var stage = {
      setNewWidth: function() {},
      moveAllStepsAndStages: function() {},
      parent: {
        allStepViews: {
          splice: function() {},
        }
      },
      childSteps: [

      ],
      model: {
        steps: {
          splice: function() {}
        }
      }
    };

    var newStep = {
      index: 1,
      nextStep: null,
      previousStep: null,
    };

    var start = 0;

    _addStepService.configureStep(stage, newStep, start);

    expect(newStep.nextStep).toEqual(null);
    expect(newStep.previousStep).toEqual(null);
  });

  it("It should test postAddStep method", function() {

    var stage = {
      stageHeader: function() {},
      parent: {
        setDefaultWidthHeight: function() {}
      }
    };

    var newStep = {
      circle: {
        moveCircle: function() {},
        getCircle: function() {},
        manageClick: function() {}
      }
    };

    var $scope = {
      applyValues: function() {}
    };

    spyOn(_correctNumberingService, 'correctNumbering').and.returnValue(true);
    spyOn(_circleManager, 'addRampLines').and.returnValue(true);

    spyOn(newStep.circle, 'moveCircle');
    spyOn(newStep.circle, 'getCircle');
    spyOn(newStep.circle, 'manageClick');

    spyOn(stage, 'stageHeader');
    spyOn(stage.parent, 'setDefaultWidthHeight');

    spyOn($scope, 'applyValues');

    _addStepService.postAddStep(stage, newStep, $scope);

    expect(_correctNumberingService.correctNumbering).toHaveBeenCalled();
    expect(_circleManager.addRampLines).toHaveBeenCalled();

    expect(newStep.circle.moveCircle).toHaveBeenCalled();
    expect(newStep.circle.getCircle).toHaveBeenCalled();
    expect(newStep.circle.manageClick).toHaveBeenCalled();

    expect(stage.stageHeader).toHaveBeenCalled();
    expect(stage.parent.setDefaultWidthHeight).toHaveBeenCalled();

    expect($scope.applyValues).toHaveBeenCalled();
  });
});
