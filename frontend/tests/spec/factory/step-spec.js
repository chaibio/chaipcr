describe("Testing functionalities of step", function() {

  /*beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _step;

  beforeEach(inject(function(step) {
    _step = step;
  }));


  it("should test step", function() {
    expect("a").toEqual("a");
  });*/
  
  var step, _step,  _circle, _previouslySelected, _stepGraphics, _constants;

  beforeEach(function() {

    module('ChaiBioTech', function($provide) {

      $provide.value('IsTouchScreen', function () {});
      $provide.value('circle', function() {
        return {
          name: "circle",
          getLeft: function() {},
          getTop: function() {},
          getUniqueId: function() {},
          addImages: function() {},
          render: function() {}
        };
      });
    });

    inject(function($injector) {
      _circle = $injector.get('circle');
      _previouslySelected = $injector.get('previouslySelected');
      _stepGraphics = $injector.get('stepGraphics');
      _constants = $injector.get('constants');
      _step = $injector.get('step');
    });

    var model = {
      collect_data: true,
      ramp: {
        collect_data: true,
      }
    };

    parentStage = {
      name: "stage",
      canvas: {
        name: "canvas",
        remove: function() {},
        renderAll: function() {}
      }
    };

    var index = 1;

    $scope = {
      name: "$scope"
    };

    step = new _step(model, parentStage, index, $scope);

  });

  it("It should test initial state of step", function() {

    //expect(2).toEqual(1);
    expect(step.stepMovedDirection).toEqual(null);
    expect(step.model.collect_data).toEqual(true);
    expect(step.parentStage.name).toEqual("stage");
    expect(step.index).toEqual(1);
    expect(step.canvas.name).toEqual("canvas");
    expect(step.myWidth).toEqual(_constants.stepWidth);
    expect(step.$scope.name).toEqual("$scope");
    expect(step.nextIsMoving).toEqual(null);
    expect(step.previousIsMoving).toEqual(null);
    expect(step.nextStep).toEqual(null);
    expect(step.previousStep).toEqual(null);
    expect(step.gatherDataDuringStep).toEqual(true);
    expect(step.gatherDataDuringRamp).toEqual(true);
    expect(step.shrinked).toEqual(false);
    expect(step.shadowText).toEqual("0px 1px 2px rgba(0, 0, 0, 0.5)");
    expect(step.visualComponents).toEqual(jasmine.any(Object));
  });

  it("It should test setLeft method", function() {
    
    step.parentStage = {
      left: 100,
    };

    step.index = 2;

    step.myWidth = 150;

    step.setLeft();

    expect(step.left).toEqual(step.parentStage.left + 3 + (step.index * step.myWidth));
  });

  it("It should test toggleComponents method", function() {

    var state = true;

    step.circle = {
      stepDataGroup: {
        setVisible: function() {}
      },
      gatherDataOnScroll: {
        setVisible: function() {}
      },
      circleGroup: {
        setVisible: function() {}
      },
      gatherDataDuringRampGroup: {
        setVisible: function() {}
      },
    };

    step.closeImage = {
      setVisible: function() {}
    };

    step.stepName = {
      setVisible: function() {}
    };

    step.numberingTextCurrent = {
      setVisible: function() {}
    };

    step.numberingTextTotal = {
      setVisible: function() {}
    };

    spyOn(step.circle.stepDataGroup, "setVisible");
    spyOn(step.circle.gatherDataOnScroll, "setVisible");
    spyOn(step.circle.circleGroup, "setVisible");
    spyOn(step.circle.gatherDataDuringRampGroup, "setVisible");

    spyOn(step.closeImage, "setVisible");
    spyOn(step.stepName, "setVisible");
    spyOn(step.numberingTextCurrent, "setVisible");
    spyOn(step.numberingTextTotal, "setVisible");

    step.toggleComponents(state);

    expect(step.circle.stepDataGroup.setVisible).toHaveBeenCalled();
    expect(step.circle.gatherDataOnScroll.setVisible).toHaveBeenCalled();
    expect(step.circle.circleGroup.setVisible).toHaveBeenCalled();
    expect(step.circle.gatherDataDuringRampGroup.setVisible).toHaveBeenCalled();

    expect(step.closeImage.setVisible).toHaveBeenCalled();
    expect(step.stepName.setVisible).toHaveBeenCalled();
    expect(step.numberingTextCurrent.setVisible).toHaveBeenCalled();
    expect(step.numberingTextTotal.setVisible).toHaveBeenCalled();
    
  });

  it("It should test moveStep method", function() {

    var action = 1;
    var callSetLeft = true;

    step.stepGroup = {
      set: function() {},
      setCoords: function() {}
    };

    step.closeImage = {
      set: function() {},
      setCoords: function() {}
    };

    step.dots = {
      set: function() {},
      setCoords: function() {}
    };

    step.rampSpeedGroup = {
      set: function() {},
      setCoords: function() {}
    };

    step.circle = {
      getUniqueId: function() {}
    };

    spyOn(step, "setLeft");
    spyOn(step, "getUniqueName");
    
    spyOn(step.stepGroup, "set");
    spyOn(step.stepGroup, "setCoords");

    spyOn(step.closeImage, "set");
    spyOn(step.closeImage, "setCoords");

    spyOn(step.dots, "set");
    spyOn(step.dots, "setCoords");

    spyOn(step.rampSpeedGroup, "set");
    spyOn(step.rampSpeedGroup, "setCoords");

    spyOn(step.circle, "getUniqueId");

    step.moveStep(action, callSetLeft);

    expect(step.setLeft).toHaveBeenCalled();
    expect(step.getUniqueName).toHaveBeenCalled();

    expect(step.closeImage.set).toHaveBeenCalled();
    expect(step.closeImage.setCoords).toHaveBeenCalled();

    expect(step.dots.set).toHaveBeenCalled();
    expect(step.dots.setCoords).toHaveBeenCalled();

    expect(step.rampSpeedGroup.set).toHaveBeenCalled();
    expect(step.rampSpeedGroup.setCoords).toHaveBeenCalled();

    expect(step.circle.getUniqueId).toHaveBeenCalled();
  });

  it("It should test moveStep method, when callSetLeft = false", function() {

    var action = 1;
    var callSetLeft = false;

    step.stepGroup = {
      set: function() {},
      setCoords: function() {}
    };

    step.closeImage = {
      set: function() {},
      setCoords: function() {}
    };

    step.dots = {
      set: function() {},
      setCoords: function() {}
    };

    step.rampSpeedGroup = {
      set: function() {},
      setCoords: function() {}
    };

    step.circle = {
      getUniqueId: function() {}
    };

    spyOn(step, "setLeft");
    spyOn(step, "getUniqueName");
    
    spyOn(step.stepGroup, "set");
    spyOn(step.stepGroup, "setCoords");

    spyOn(step.closeImage, "set");
    spyOn(step.closeImage, "setCoords");

    spyOn(step.dots, "set");
    spyOn(step.dots, "setCoords");

    spyOn(step.rampSpeedGroup, "set");
    spyOn(step.rampSpeedGroup, "setCoords");

    spyOn(step.circle, "getUniqueId");

    step.moveStep(action, callSetLeft);

    expect(step.setLeft).not.toHaveBeenCalled();
    expect(step.getUniqueName).toHaveBeenCalled();

    expect(step.closeImage.set).toHaveBeenCalled();
    expect(step.closeImage.setCoords).toHaveBeenCalled();

    expect(step.dots.set).toHaveBeenCalled();
    expect(step.dots.setCoords).toHaveBeenCalled();

    expect(step.rampSpeedGroup.set).toHaveBeenCalled();
    expect(step.rampSpeedGroup.setCoords).toHaveBeenCalled();

    expect(step.circle.getUniqueId).toHaveBeenCalled();
  });

  it("It should test deleteAllStepContents method", function() {

    step.visualComponents = {
      circle: {

      },
      dots: {

      }
    };

    step.circle = {
      removeContents: function() {}
    };

    spyOn(step.canvas, "remove");
    spyOn(step.circle, "removeContents");

    step.deleteAllStepContents();

    expect(step.canvas.remove).toHaveBeenCalled();
    expect(step.circle.removeContents).toHaveBeenCalled();

  });

  describe("Testing wireNextAndPreviousStep method in different scenarios", function() {

    it("It should test wireNextAndPreviousStep method when step has nextStep or when the step is very first one", function() {

      step.nextStep  = {
        name: "nextStep"
      };

      var selected = step.wireNextAndPreviousStep({}, {});

      expect(selected.name).toEqual("nextStep");
      expect(step.nextStep.previousStep).toEqual(null);
    });

    it("it should test wireNextAndPreviousStep method, when the step is the last one", function() {

      step.previousStep = {
        name: "previousStep"
      };

      var selected = step.wireNextAndPreviousStep({}, {});

      expect(selected.name).toEqual("previousStep");
      expect(step.previousStep.nextStep).toEqual(null);
    });

    it("It should test wireNextAndPreviousStep method, when step has next and previous", function() {

      step.previousStep = {
        name: "previousStep"
      };

      step.nextStep = {
        name: "nextStep"
      };

      var selected = step.wireNextAndPreviousStep({}, {});

      expect(selected.name).toEqual("nextStep");
      expect(step.previousStep.nextStep.name).toEqual("nextStep");
      expect(step.nextStep.previousStep.name).toEqual("previousStep");
    });
  });

  it("It should test configureStepName method", function() {

    step.stepName = {};
    
    step.model = {
      name: "step1"
    };

    spyOn(step, "numberingValue").and.returnValue();

    step.configureStepName();

    expect(step.stepName.text).toEqual("step1");
    expect(step.numberingValue).toHaveBeenCalled();
  });

  it("It should test configureStepName method, when model.name = null", function() {

    step.stepName = {};
    
    step.model = {
      name: null,
      index: 2,
    };

    spyOn(step, "numberingValue").and.returnValue();

    step.configureStepName();

    expect(step.numberingValue).toHaveBeenCalled();
    expect(step.stepNameText).toEqual('Step ' + (step.index + 1));
    expect(step.stepName.text).toEqual('Step ' + (step.index + 1));
  });

  it("It should test addCircle method", function() {

    step.addCircle();

    expect(step.circle.name).toEqual("circle");
  });

  it("It should test getUniqueName method", function() {

    step.model = {
      id: 1000
    };

    step.parentStage = {
      index: 100
    };

    step.getUniqueName();

    expect(step.uniqueName).toEqual(step.model.id + step.parentStage.index + "step");
  });

  it("It should test showHideRamp method", function() {

    step.model = {
      ramp: {
        rate: "2"
      }
    };

    step.rampSpeedGroup = {
      setVisible: function() {},

    };
    step.rampSpeedText = {
      width: 100,
    };

    step.underLine = {
      setWidth: function() {}
    };

    spyOn(step.canvas, "renderAll");
    spyOn(step.rampSpeedGroup, "setVisible");
    spyOn(step.underLine, "setWidth");

    step.showHideRamp();

    expect(step.rampSpeedText.text).toEqual("2º C/s");
    expect(step.rampSpeedGroup.setVisible).toHaveBeenCalledWith(true);
    expect(step.underLine.setWidth).toHaveBeenCalled();
  });

  it("It should test showHideRamp method when ramp text to be hide", function() {

    step.model = {
      ramp: {
        rate: "10"
      }
    };

    step.rampSpeedGroup = {
      setVisible: function() {},

    };
    step.rampSpeedText = {
      width: 100,
    };

    step.underLine = {
      setWidth: function() {}
    };

    spyOn(step.canvas, "renderAll");
    spyOn(step.rampSpeedGroup, "setVisible");
    spyOn(step.underLine, "setWidth");

    step.showHideRamp();

    expect(step.rampSpeedText.text).toEqual("10º C/s");
    expect(step.rampSpeedGroup.setVisible).toHaveBeenCalledWith(false);
    expect(step.underLine.setWidth).not.toHaveBeenCalled();
  });

  it("It should test adjustRampSpeedPlacing method", function() {

    step.circle = {
      top: 12
    };

    step.rampSpeedGroup = {
      setTop: function() {},
    };

    spyOn(step.rampSpeedGroup, "setTop");
    step.adjustRampSpeedPlacing();
    expect(step.rampSpeedGroup.setTop).toHaveBeenCalledWith(step.circle.top + 20);
  });

  it("It should test adjustRampSpeedLeft method", function() {

    step.circle = {
      runAlongCircle: function() {}
    };

    spyOn(step.circle, "runAlongCircle");

    step.adjustRampSpeedLeft();
    
    expect(step.circle.runAlongCircle).toHaveBeenCalled();
  });
});
