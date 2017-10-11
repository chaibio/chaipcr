describe("Testing step vertical line's line", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _verticalLineStepLine;

  beforeEach(inject(function(verticalLineStepLine) {
    _verticalLineStepLine =  new verticalLineStepLine();
  }));

  it("It should test stroke property", function() {
    expect(_verticalLineStepLine.stroke).toEqual('black');
  });

  it("It should test strokeWidth property", function() {
    expect(_verticalLineStepLine.strokeWidth).toEqual(2);
  });

  it("It should test originX property", function() {
    expect(_verticalLineStepLine.originX).toEqual('left');
  });

  it("It should test originY property", function() {
    expect(_verticalLineStepLine.originY).toEqual('top');
  });

});
