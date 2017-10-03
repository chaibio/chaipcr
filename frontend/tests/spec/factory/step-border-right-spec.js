describe("Testing steps's borderRight factory", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _borderRight,
    step = {
      myWidth: 128
    };

  beforeEach(inject(function(borderRight) {
    _borderRight = new borderRight(step);
  }));

  it("It should check the left of the borderRight", function() {
    expect(_borderRight.left).toEqual(step.myWidth - 2);
  });

  it("It should check the left of the stroke", function() {
    expect(_borderRight.stroke).toEqual('#ff9f00');
  });

  it("It should check the left of the strokeWidth", function() {
    expect(_borderRight.strokeWidth).toEqual(1);
  });

  it("It should check the left of the selectable", function() {
    expect(_borderRight.selectable).toBeFalsy();
  });
});
