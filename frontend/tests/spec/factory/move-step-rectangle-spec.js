describe("Testing moveStepRectangle", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStepRectangle;

  beforeEach(inject(function(moveStepRectangle) {
    _moveStepRectangle = new moveStepRectangle();
  }));

  it("It should test fill property", function() {
    expect(_moveStepRectangle.fill).toEqual("white");
  });

  it("It should test width property", function() {
    expect(_moveStepRectangle.width).toEqual(128);
  });

  it("It should test selectable property", function() {
    expect(_moveStepRectangle.selectable).toEqual(false);
  });

  it("It should test name property", function() {
    expect(_moveStepRectangle.name).toEqual("moveStepRectangle");
  });

  it("It should test height property", function() {
    expect(_moveStepRectangle.height).toEqual(72);
  });

  it("It should test left property", function() {
    expect(_moveStepRectangle.left).toEqual(0);
  });

  it("It should test rx property", function() {
    expect(_moveStepRectangle.rx).toEqual(1);
  });

});
