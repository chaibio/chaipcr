describe("Testing autoDeltaStartCycle properties", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _autoDeltaStartCycle;
  beforeEach(inject(function(autoDeltaStartCycle) {

    _autoDeltaStartCycle = new autoDeltaStartCycle();
  }));

  it("It should check the text of autoDeltaStartCycle", function() {
    expect(_autoDeltaStartCycle.text).toEqual('Start Cycle: 5');
  });

  it("It should check the autoDeltaStartCycle fill property", function() {
    expect(_autoDeltaStartCycle.fill).toEqual('white');
  });

  it("It should check the autoDeltaStartCycle fill fontSize", function() {
    expect(_autoDeltaStartCycle.fontSize).toEqual(12);
  });

  it("It should check the autoDeltaStartCycle fill top", function() {
    expect(_autoDeltaStartCycle.top).toEqual(15);
  });

  it("It should check the autoDeltaStartCycle fill left", function() {
    expect(_autoDeltaStartCycle.left).toEqual(0);
  });

  it("It should check the autoDeltaStartCycle fill fontFamily", function() {
    expect(_autoDeltaStartCycle.fontFamily).toEqual('dinot-bold');
  });

  it("It should check the autoDeltaStartCycle fill fontFamily", function() {
    expect(_autoDeltaStartCycle.fontFamily).toEqual('dinot-bold');
  });

  it("It should check the autoDeltaStartCycle fill selectable", function() {
    expect(_autoDeltaStartCycle.selectable).toBeFalsy();
  });

  it("It should check the autoDeltaStartCycle fill selectable", function() {
    expect(_autoDeltaStartCycle.selectable).toBeFalsy();
  });
});
