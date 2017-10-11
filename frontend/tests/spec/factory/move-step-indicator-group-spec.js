describe("Testing moveStepIndicatorGroup", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStepIndicatorGroup;

  beforeEach(inject(function(moveStepRectangle, moveStepTemperatureText, moveStepIndicatorGroup) {

    var component  = [
      new moveStepRectangle(),
      new moveStepTemperatureText(),
    ];

    _moveStepIndicatorGroup = new moveStepIndicatorGroup(component);

  }));

  it("It should check the name property", function() {
    expect(_moveStepIndicatorGroup.name).toEqual("dragStepGroup");
  });

  it("It should check the hasBorders property", function() {
    expect(_moveStepIndicatorGroup.hasBorders).toEqual(false);
  });

  it("It should check the visible property", function() {
    expect(_moveStepIndicatorGroup.visible).toEqual(false);
  });

  it("It should check the hasControls property", function() {
    expect(_moveStepIndicatorGroup.hasControls).toEqual(false);
  });

  it("It should check the lockMovementY property", function() {
    expect(_moveStepIndicatorGroup.lockMovementY).toEqual(true);
  });

  it("It should check the  selectable property", function() {
    expect(_moveStepIndicatorGroup. selectable).toEqual(true);
  });

  it("It should check the width property", function() {
    expect(_moveStepIndicatorGroup.width).toEqual(128);
  });

  it("It should check the height property", function() {
    expect(_moveStepIndicatorGroup.height).toEqual(72);
  });

  it("It should check the top property", function() {
    expect(_moveStepIndicatorGroup.top).toEqual(326);
  });

  it("It should check the left property", function() {
    expect(_moveStepIndicatorGroup.left).toEqual(38);
  });

  it("It should check the originY property", function() {
    expect(_moveStepIndicatorGroup.originY).toEqual("top");
  });

  it("It should check the originX property", function() {
    expect(_moveStepIndicatorGroup.originX).toEqual("left");
  });


});
