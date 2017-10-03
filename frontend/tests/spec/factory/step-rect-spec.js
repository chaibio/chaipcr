describe("Testing step rect", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stepRect, step = {}, _contants;

  beforeEach(inject(function(stepRect, constants) {
    _stepRect = new stepRect(step);
    _contants = constants;
  }));

  it("It should check the fill property", function() {
    expect(_stepRect.fill).toEqual("#FFB300");
  });

  it("It should check the width property", function() {
    expect(_stepRect.width).toEqual(_contants.stepWidth);
  });

  it("It should check the height property", function() {
    expect(_stepRect.height).toEqual(363);
  });

  it("It should check the selectable property", function() {
    expect(_stepRect.selectable).toBeFalsy();
  });

  it("It should check the name property", function() {
    expect(_stepRect.name).toEqual("step");
  });
});
