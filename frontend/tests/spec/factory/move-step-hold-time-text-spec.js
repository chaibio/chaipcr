describe("Testing moveStepHoldTimeText", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStepHoldTimeText;
  beforeEach(inject(function(moveStepHoldTimeText) {
    _moveStepHoldTimeText = new moveStepHoldTimeText();
  }));

  it("It should check text property", function() {
    expect(_moveStepHoldTimeText.text).toEqual("0:05");
  });

  it("It should check fill property", function() {
    expect(_moveStepHoldTimeText.fill).toEqual("black");
  });

  it("It should check fontSize property", function() {
    expect(_moveStepHoldTimeText.fontSize).toEqual(16);
  });

  it("It should check selectable property", function() {
    expect(_moveStepHoldTimeText.selectable).toEqual(false);
  });

  it("It should check originX property", function() {
    expect(_moveStepHoldTimeText.originX).toEqual("left");
  });

  it("It should check originY property", function() {
    expect(_moveStepHoldTimeText.originY).toEqual("top");
  });

  it("It should check top property", function() {
    expect(_moveStepHoldTimeText.top).toEqual(12);
  });

  it("It should check left property", function() {
    expect(_moveStepHoldTimeText.left).toEqual(72);
  });

  it("It should check fontFamily property", function() {
    expect(_moveStepHoldTimeText.fontFamily).toEqual('dinot');
  });

});
