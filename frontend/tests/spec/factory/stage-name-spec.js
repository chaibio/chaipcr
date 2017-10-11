describe("Testing stage name", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageName;
  beforeEach(inject(function(stageName) {

    _stageName = new stageName();
  }));

  it("It should check the stageName text value", function() {
    expect(_stageName.text).toEqual("text comes here");
  });

  it("It should check check fill property", function() {
    expect(_stageName.fill).toEqual("white");
  });

  it("It should check fontWeight", function() {
    expect(_stageName.fontWeight).toEqual('400');
  });

  it("It should check fontSize", function() {
    expect(_stageName.fontSize).toEqual(12);
  });

  it("It should check fontFamily", function() {
    expect(_stageName.fontFamily).toEqual('dinot');
  });

  it("It should check selectable", function() {
    expect(_stageName.selectable).toBeTruthy();
  });
});
