describe("Testing vertical line, line specs", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _verticalLineLine;

  beforeEach(inject(function(verticalLineLine) {
    _verticalLineLine =  new verticalLineLine();
  }));

  it("It should check the left property", function() {
    expect(_verticalLineLine.left).toEqual(68);
  });

  it("It should check the top property", function() {
    expect(_verticalLineLine.top).toEqual(58);
  });

  it("It should check the stroke property", function() {
    expect(_verticalLineLine.stroke).toEqual('black');
  });

  it("It should check the strokeWidth property", function() {
    expect(_verticalLineLine.strokeWidth).toEqual(2);
  });

  it("It should check the top property", function() {
    expect(_verticalLineLine.top).toEqual(58);
  });

  it("It should check the x1 property", function() {
    expect(_verticalLineLine.x1).toEqual(0);
  });

  it("It should check the y1 property", function() {
    expect(_verticalLineLine.y1).toEqual(0);
  });

  it("It should check the x2 property", function() {
    expect(_verticalLineLine.x2).toEqual(0);
  });

  it("It should check the y2 property", function() {
    expect(_verticalLineLine.y2).toEqual(336);
  });

});
