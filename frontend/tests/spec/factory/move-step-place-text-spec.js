describe("Testing moveStepPlaceText", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStepPlaceText;

  beforeEach(inject(function(moveStepPlaceText) {
    _moveStepPlaceText = new moveStepPlaceText();
  }));

  it("It should test text property", function() {
    expect(_moveStepPlaceText.text).toEqual("01/01");
  });

  it("It should test fill property", function() {
    expect(_moveStepPlaceText.fill).toEqual("black");
  });

  it("It should test fontSize property", function() {
    expect(_moveStepPlaceText.fontSize).toEqual(16);
  });

  it("It should test selectable property", function() {
    expect(_moveStepPlaceText.selectable).toEqual(false);
  });

  it("It should test originX property", function() {
    expect(_moveStepPlaceText.originX).toEqual("left");
  });

  it("It should test originY property", function() {
    expect(_moveStepPlaceText.originY).toEqual("top");
  });

  it("It should test top property", function() {
    expect(_moveStepPlaceText.top).toEqual(30);
  });

  it("It should test left property", function() {
    expect(_moveStepPlaceText.left).toEqual(72);
  });

  it("It should test fontFamily property", function() {
    expect(_moveStepPlaceText.fontFamily).toEqual('dinot');
  });

});
