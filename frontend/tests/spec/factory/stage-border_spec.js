describe("Testing stageBorderLeft", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageBorderLeft;
  beforeEach(inject(function(stageBorderLeft) {
    _stageBorderLeft = new stageBorderLeft();
  }));

  it("It should be a fabric Line object with strokeWidth", function() {
    expect(_stageBorderLeft.strokeWidth).toBe(2);
  });

  it("It should be a fabric Line object with selectable ", function() {
    expect(_stageBorderLeft.selectable).toBeFalsy();
  });

  it("It should be a fabric Line object with stroke", function() {
    expect(_stageBorderLeft.stroke).toEqual('#ff9f00');
  });

  it("It should be a fabric Line object with left", function() {
    expect(_stageBorderLeft.left).toEqual(0);
  });

  it("It should be a fabric Line object with x1", function() {
    expect(_stageBorderLeft.x1).toEqual(0);
  });

  it("It should be a fabric Line object with x2", function() {
    expect(_stageBorderLeft.x2).toEqual(0);
  });

  it("It should be a fabric Line object with y1", function() {
    expect(_stageBorderLeft.y1).toEqual(70);
  });

  it("It should be a fabric Line object with y2", function() {
    expect(_stageBorderLeft.y2).toEqual(390);
  });

});
