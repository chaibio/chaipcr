describe("Testing autoDeltaTempTime", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _autoDeltaTempTime;
  beforeEach(inject(function(autoDeltaTempTime) {
    _autoDeltaTempTime = new autoDeltaTempTime();
  }));

  it("It should check autoDeltaTempTime text", function() {
    expect(_autoDeltaTempTime.text).toEqual('-0.15ºC, +5.0s');
  });

  it("It should check autoDeltaTempTime fill", function() {
    expect(_autoDeltaTempTime.fill).toEqual('white');
  });

  it("It should check autoDeltaTempTime fontSize", function() {
    expect(_autoDeltaTempTime.fontSize).toEqual(12);
  });

  it("It should check autoDeltaTempTime top", function() {
    expect(_autoDeltaTempTime.top).toEqual(0);
  });

  it("It should check autoDeltaTempTime left", function() {
    expect(_autoDeltaTempTime.left).toEqual(0);
  });

  it("It should check autoDeltaTempTime fontFamily", function() {
    expect(_autoDeltaTempTime.fontFamily).toEqual('dinot-regular');
  });

  it("It should check autoDeltaTempTime selectable", function() {
    expect(_autoDeltaTempTime.left).toBeFalsy();
  });

});
