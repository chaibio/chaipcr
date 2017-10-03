describe("Testing rampSpeedGroup", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _rampSpeedGroup, step = {
    left: 1000,
    model: {
      ramp: {
        rate: 10
      }
    }
  };

  beforeEach(inject(function(rampSpeedGroup) {
    _rampSpeedGroup = new rampSpeedGroup(step);

  }));

  it("it should check if rampSpeedText is available in step", function() {
    //console.log(step);
    expect(step.rampSpeedText).toEqual(jasmine.any(Object));
  });

  it("it should check if underLine is available in step", function() {
    //console.log(step);
    expect(step.underLine).toEqual(jasmine.any(Object));
  });

  it("it should check left property", function() {
    expect(_rampSpeedGroup.left).toEqual(step.left + 5);
  });

  it("it should check selectable property", function() {
    expect(_rampSpeedGroup.selectable).toBeTruthy();
  });

  it("it should check hasControls property", function() {
    expect(_rampSpeedGroup.hasControls).toBeTruthy();
  });

  it("it should check top property", function() {
    expect(_rampSpeedGroup.top).toEqual(0);
  });

  it("it should check hasControls property", function() {
    expect(_rampSpeedGroup.evented).toBeFalsy();
  });

});
