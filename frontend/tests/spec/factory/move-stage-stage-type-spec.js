describe("Testing move-stage-type text on movestage white rectangle", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStageType;

  beforeEach(inject(function(moveStageType) {

    _moveStageType = new moveStageType();
  }));

  it("It should check fill property", function() {
    expect(_moveStageType.fill).toEqual('black');
  });

  it("It should check text property", function() {
    expect(_moveStageType.text).toEqual('HOLDING');
  });

  it("It should check fontSize property", function() {
    expect(_moveStageType.fontSize).toEqual(12);
  });

  it("It should check selectable property", function() {
    expect(_moveStageType.selectable).toEqual(false);
  });

  it("It should check top property", function() {
    expect(_moveStageType.top).toEqual(30);
  });

  it("It should check left property", function() {
    expect(_moveStageType.left).toEqual(35);
  });

  it("It should check fontFamily property", function() {
    expect(_moveStageType.fontFamily).toEqual("dinot-regular");
  });

});
