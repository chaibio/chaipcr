describe("Testing moveStepIndexText", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStepIndexText;

  beforeEach(inject(function(moveStepIndexText) {
    _moveStepIndexText = new moveStepIndexText();
  }));

  it("It should test text property", function() {
    expect(_moveStepIndexText.text).toEqual("02");
  });

  it("It should test fill property", function() {
    expect(_moveStepIndexText.fill).toEqual("black");
  });

  it("It should test fontSize property", function() {
    expect(_moveStepIndexText.fontSize).toEqual(16);
  });

  it("It should test selectable property", function() {
    expect(_moveStepIndexText.selectable).toEqual(false);
  });

  it("It should test originX property", function() {
    expect(_moveStepIndexText.originX).toEqual("left");
  });

  it("It should test originY property", function() {
    expect(_moveStepIndexText.originY).toEqual("top");
  });

  it("It should test top property", function() {
    expect(_moveStepIndexText.top).toEqual(30);
  });

  it("It should test left property", function() {
    expect(_moveStepIndexText.left).toEqual(34);
  });

  it("It should test fontFamily property", function() {
    expect(_moveStepIndexText.fontFamily).toEqual('dinot-bold');
  });


});
