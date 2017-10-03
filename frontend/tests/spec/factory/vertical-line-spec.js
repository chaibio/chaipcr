describe("Testing vertical line group", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));
  var _verticalLine, _verticalLineLine, _verticalLineSmallCircle, _verticalLineSmallCircleTop;

  beforeEach(inject(function(verticalLineGroup, verticalLineLine, verticalLineSmallCircle, verticalLineSmallCircleTop) {
    _verticalLine = new verticalLineGroup([
      new verticalLineLine(),
      new verticalLineSmallCircle(),
      new verticalLineSmallCircleTop()
    ]);
  }));

  it("It should check if vertical line exist", function() {
    expect(_verticalLine).toEqual(jasmine.any(Object));
  });

  it("It should check the vertical line name property", function() {
    expect(_verticalLine.name).toEqual("vertica");
  });

  it("It should check the vertical line visible property", function() {
    expect(_verticalLine.visible).toEqual(false);
  });

  it("It should check the vertical line hasBorders property", function() {
    expect(_verticalLine.hasBorders).toEqual(false);
  });

  it("It should check the vertical line hasControls property", function() {
    expect(_verticalLine.hasControls).toEqual(false);
  });

  it("It should check the vertical line lockMovementY property", function() {
    expect(_verticalLine.lockMovementY).toEqual(true);
  });

  it("It should check the vertical line  selectable property", function() {
    expect(_verticalLine.selectable).toEqual(true);
  });

  it("It should check the vertical line top property", function() {
    expect(_verticalLine.top).toEqual(56);
  });

  it("It should check the vertical line left property", function() {
    expect(_verticalLine.left).toEqual(62);
  });

});
