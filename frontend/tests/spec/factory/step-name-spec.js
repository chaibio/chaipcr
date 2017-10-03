describe("Testing step name ", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stepName, name = 'chaibio';
  beforeEach(inject(function(stepName) {
    _stepName = new stepName(name);
  }));

  it("It should check the text property", function() {
    expect(_stepName.text).toEqual(name);
  });

  it("It should check the fill property", function() {
    expect(_stepName.fill).toEqual('white');
  });

  it("It should check the fontSize property", function() {
    expect(_stepName.fontSize).toEqual(12);
  });

  it("It should check the top property", function() {
    expect(_stepName.top).toEqual(20);
  });

  it("It should check the left property", function() {
    expect(_stepName.left).toEqual(-1);
  });

  it("It should check the fontFamily property", function() {
    expect(_stepName.fontFamily).toEqual('dinot-regular');
  });

  it("It should check the selectable property", function() {
    expect(_stepName.selectable).toBeFalsy();
  });

});
