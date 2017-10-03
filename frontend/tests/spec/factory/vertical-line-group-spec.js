describe("Testing vertical line group", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));
  var _verticalLineGroup, _verticalLineLine, _verticalLineSmallCircle, _verticalLineSmallCircleTop;

  beforeEach(inject(function(verticalLineGroup, verticalLineLine, verticalLineSmallCircle, verticalLineSmallCircleTop) {
    _verticalLineGroup = new verticalLineGroup([
      new verticalLineLine(),
      new verticalLineSmallCircle(),
      new verticalLineSmallCircleTop()
    ]);
  }));

  it("It should check if vertical line exist", function() {
    expect(_verticalLineGroup).toEqual(jasmine.any(Object));
  });

  it("It should check the vertical line name property", function() {
    expect(_verticalLineGroup.name).toEqual("vertica");
  });

  it("It should check the vertical line visible property", function() {
    expect(_verticalLineGroup.visible).toEqual(false);
  });

  it("It should check the vertical line hasBorders property", function() {
    expect(_verticalLineGroup.hasBorders).toEqual(false);
  });

  it("It should check the vertical line hasControls property", function() {
    expect(_verticalLineGroup.hasControls).toEqual(false);
  });

  it("It should check the vertical line lockMovementY property", function() {
    expect(_verticalLineGroup.lockMovementY).toEqual(true);
  });

  it("It should check the vertical line  selectable property", function() {
    expect(_verticalLineGroup.selectable).toEqual(true);
  });

  it("It should check the vertical line top property", function() {
    expect(_verticalLineGroup.top).toEqual(56);
  });

  it("It should check the vertical line left property", function() {
    expect(_verticalLineGroup.left).toEqual(62);
  });

});
