describe("Testing rampSpeedText", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _rampSpeedText, step = {
    model: {
      ramp: {
        rate: 10
      }
    }
  };
  beforeEach(inject(function(rampSpeedText) {
    _rampSpeedText = new rampSpeedText(step);
  }));

  it("It should check rampSpeedNumber", function() {
    expect(step.rampSpeedNumber).toEqual(step.model.ramp.rate);
  });

  it("It should check the text property", function() {
    expect(_rampSpeedText.text).toEqual(step.rampSpeedNumber + " ºC/s");
  });

  it("It should check the fill property", function() {
    expect(_rampSpeedText.fill).toEqual('black');
  });

  it("It should check the fontSize property", function() {
    expect(_rampSpeedText.fontSize).toEqual(12);
  });

  it("It should check the fontFamily property", function() {
    expect(_rampSpeedText.fontFamily).toEqual('dinot');
  });

});
