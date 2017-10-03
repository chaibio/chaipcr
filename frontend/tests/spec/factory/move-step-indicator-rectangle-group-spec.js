describe("Testing moveStepIndicatorRectangleGroup", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStepIndicatorRectangleGroup;

  beforeEach(inject(function(moveStepRectangle, moveStepTemperatureText, moveStepIndicatorRectangleGroup) {

    var component  = [
      new moveStepRectangle(),
      new moveStepTemperatureText(),
    ];

    _moveStepIndicatorRectangleGroup = new moveStepIndicatorRectangleGroup(component);

  }));

  it("It should check the name property", function() {
    expect(_moveStepIndicatorRectangleGroup.name).toEqual("dragStepGroupRectangle");
  });

  it("It should check the hasBorders property", function() {
    expect(_moveStepIndicatorRectangleGroup.hasBorders).toEqual(false);
  });

  it("It should check the visible property", function() {
    expect(_moveStepIndicatorRectangleGroup.visible).toEqual(true);
  });

  it("It should check the hasControls property", function() {
    expect(_moveStepIndicatorRectangleGroup.hasControls).toEqual(false);
  });

  it("It should check the lockMovementY property", function() {
    expect(_moveStepIndicatorRectangleGroup.lockMovementY).toEqual(true);
  });

  it("It should check the height property", function() {
    expect(_moveStepIndicatorRectangleGroup.height).toEqual(72);
  });

  it("It should check the top property", function() {
    expect(_moveStepIndicatorRectangleGroup.top).toEqual(298);
  });

  it("It should check the left property", function() {
    expect(_moveStepIndicatorRectangleGroup.left).toEqual(0);
  });

  it("It should check the originY property", function() {
    expect(_moveStepIndicatorRectangleGroup.originY).toEqual("top");
  });

  it("It should check the originX property", function() {
    expect(_moveStepIndicatorRectangleGroup.originX).toEqual("left");
  });
});
