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
        name: "canvas"
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


});
