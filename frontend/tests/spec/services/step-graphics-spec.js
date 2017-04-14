describe("Testing stepGraphics", function() {

  beforeEach(module('ChaiBioTech'));
  beforeEach(module('canvasApp'));

  var _stepGraphics;
  beforeEach(inject(function(stepGraphics) {
    _stepGraphics = stepGraphics;
  }));

  it("It should check the addName method", function() {

    var name = "chai";
    var step = {
      stepNameText: name
    };

    var sg = _stepGraphics.addName.call(step);
    expect(sg.stepName.text).toEqual(name);
  });

  it("It should check the stepFooter method, calling this method should give dots object", function() {

    var step = {
      parentStage: {
        parent: {
          editStageStatus: true
        }
      }
    };
      var sg = _stepGraphics.stepFooter.call(step);
      expect(sg.dots).toEqual(jasmine.any(Object));
  });

  it("It should check the deleteButton method, calling this method should give closeImage group object", function() {

    var step = {
      parentStage: {
        parent: {
          editStageStatus: true
        }
      },
      $scope: {
        exp_completed: true
      }
    };
    var sg = _stepGraphics.deleteButton.call(step);
    expect(sg.closeImage).toEqual(jasmine.any(Object));
  });

  it("It should check the autoDeltaDetails method autoDeltaTempTime.setText to be called", function() {

    var step = {
      autoDeltaTempTime: {
        setText: function() {

        }
      },
      autoDeltaStartCycle: {
        setText: function() {

        }
      },
      deltaGroup: {
        setVisible: function() {

        }
      },
      deltaSymbol: {
        setVisible: function() {

        }
      },
      model: {
        delta_temperature: 10,
        delta_duration_s: 15,
      },
      parentStage: {
        parent: {
          editStageStatus: false
        },
        model: {
          auto_delta: true,
          stage_type: "cycling",
          auto_delta_start_cycle: 20,
        }
      },
      $scope: {
        exp_completed: true
      }
    };

    spyOn(step.autoDeltaTempTime, "setText");
    var sg = _stepGraphics.autoDeltaDetails.call(step);
    expect(sg.autoDeltaTempTime.setText).toHaveBeenCalled();
  });

  it("It should check the autoDeltaDetails method autoDeltaStartCycle.setText to be called with startCycle ", function() {

    var step = {
      autoDeltaTempTime: {
        setText: function() {

        }
      },
      autoDeltaStartCycle: {
        setText: function() {

        }
      },
      deltaGroup: {
        setVisible: function() {

        }
      },
      deltaSymbol: {
        setVisible: function() {

        }
      },
      model: {
        delta_temperature: 10,
        delta_duration_s: 15,
      },
      parentStage: {
        parent: {
          editStageStatus: false
        },
        model: {
          auto_delta: true,
          stage_type: "cycling",
          auto_delta_start_cycle: 20,
        }
      },
      $scope: {
        exp_completed: true
      }
    };

    spyOn(step.autoDeltaStartCycle, "setText");
    var sg = _stepGraphics.autoDeltaDetails.call(step);
    expect(sg.autoDeltaStartCycle.setText).toHaveBeenCalledWith("Start Cycle: " + step.parentStage.model.auto_delta_start_cycle);
  });
});
