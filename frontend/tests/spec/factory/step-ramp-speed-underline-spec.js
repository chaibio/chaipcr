describe("Testing rampSpeedUnderline", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _rampSpeedUnderline, step = {
    rampSpeedText: {
      width: 100
    }
  };
  beforeEach(inject(function(rampSpeedUnderline) {
    _rampSpeedUnderline = new rampSpeedUnderline(step);
  }));

  it("It should check stroke property", function() {
    expect(_rampSpeedUnderline.stroke).toEqual('#ffde00');
  });

  it("It should check strokeWidth property", function() {
    expect(_rampSpeedUnderline.strokeWidth).toEqual(2);
  });

  it("It should check top property", function() {
    expect(_rampSpeedUnderline.top).toEqual(13);
  });

  it("It should check left property", function() {
    expect(_rampSpeedUnderline.left).toEqual(0);
  });

  it("It should check width property", function() {
    expect(_rampSpeedUnderline.width).toEqual(100);
  });
});
