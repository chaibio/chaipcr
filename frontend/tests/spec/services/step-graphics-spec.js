describe("Testing stepGraphics", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

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

  it("It should check the autoDeltaDetails method deltaGroup.setVisible to be called with true because editStageStatus = false ", function() {

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

    spyOn(step.deltaGroup, "setVisible");
    var sg = _stepGraphics.autoDeltaDetails.call(step);
    expect(sg.deltaGroup.setVisible).toHaveBeenCalledWith(true);
  });

  it("It should check the autoDeltaDetails method deltaSymbol.setVisible to be called with true id index = 0", function() {

    var step = {
      index: 0,
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

    spyOn(step.deltaSymbol, "setVisible");
    var sg = _stepGraphics.autoDeltaDetails.call(step);
    expect(sg.deltaSymbol.setVisible).toHaveBeenCalledWith(true);
  });

  it("It should call deltaGroup and deltaSymbol setVisible methods with false, because auto_delta is false", function() {

    var step = {
      index: 0,
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
          auto_delta: false,
          stage_type: "cycling",
          auto_delta_start_cycle: 20,
        }
      },
      $scope: {
        exp_completed: true
      }
    };

    spyOn(step.deltaSymbol, "setVisible");
    spyOn(step.deltaGroup, "setVisible");

    var sg = _stepGraphics.autoDeltaDetails.call(step);
    expect(sg.deltaSymbol.setVisible).toHaveBeenCalledWith(false);
    expect(sg.deltaGroup.setVisible).toHaveBeenCalledWith(false);
  });

  it("It should check initAutoDelta method", function() {
    var step = {
      index: 0,
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
          auto_delta: false,
          stage_type: "cycling",
          auto_delta_start_cycle: 20,
        }
      },
      $scope: {
        exp_completed: true
      }
    };

    var sg = _stepGraphics.autoDeltaDetails.call(step);
    expect(sg.deltaGroup).toEqual(jasmine.any(Object));
    expect(sg.deltaSymbol).toEqual(jasmine.any(Object));
  });

  it("It should check initNumberText method", function() {
    var step = {
      index: 0,
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
          auto_delta: false,
          stage_type: "cycling",
          auto_delta_start_cycle: 20,
        }
      },
      $scope: {
        exp_completed: true
      }
    };

    var sg = _stepGraphics.initNumberText.call(step);
    expect(sg.numberingTextCurrent).toEqual(jasmine.any(Object));
    expect(sg.numberingTextTotal).toEqual(jasmine.any(Object));
  });

  it("It should check addBorderRight method", function() {
    var step = {
      index: 0,
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
          auto_delta: false,
          stage_type: "cycling",
          auto_delta_start_cycle: 20,
        }
      },
      $scope: {
        exp_completed: true
      }
    };

    var sg = _stepGraphics.addBorderRight.call(step);
    expect(sg.borderRight).toEqual(jasmine.any(Object));
  });

  it("It should check rampSpeed method", function() {
    var step = {
      index: 0,
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
        ramp: {
          rate: 4
        }
      },
      parentStage: {
        parent: {
          editStageStatus: false
        },
        model: {
          auto_delta: false,
          stage_type: "cycling",
          auto_delta_start_cycle: 20,
        }
      },
      $scope: {
        exp_completed: true
      }
    };

    var sg = _stepGraphics.rampSpeed.call(step);
    expect(sg.rampSpeedGroup).toEqual(jasmine.any(Object));
  });

  it("It should check stepComponents method", function() {
    var step = {
      index: 0,
      hitPoint: {

      },
      stepRect: {

      },

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
        ramp: {
          rate: 4
        }
      },
      parentStage: {
        parent: {
          editStageStatus: false
        },
        model: {
          auto_delta: false,
          stage_type: "cycling",
          auto_delta_start_cycle: 20,
        }
      },
      $scope: {
        exp_completed: true
      }
    };
    // _stepGraphics.stepComponents.call(step);
    //expect(sg.hitPoint).toEqual(jasmine.any(Object));
    //expect(sg.stepRect).toEqual(jasmine.any(Object));
    //expect(sg.stepGroup).toEqual(jasmine.any(Object));
  });

});
