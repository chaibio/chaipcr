describe("Testing step vertica line's small circle at the end of the line", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _verticalLineStepSmallCircleTop;

  beforeEach(inject(function(verticalLineStepSmallCircleTop) {
    _verticalLineStepSmallCircleTop =  new verticalLineStepSmallCircleTop();
  }));

  it("It should check the radius property", function() {
    expect(_verticalLineStepSmallCircleTop.radius).toEqual(5);
  });

  it("It should check the fill property", function() {
    expect(_verticalLineStepSmallCircleTop.fill).toEqual('black');
  });

  it("It should check the originX property", function() {
    expect(_verticalLineStepSmallCircleTop.originX).toEqual('center');
  });

  it("It should check the originY property", function() {
    expect(_verticalLineStepSmallCircleTop.originY).toEqual('center');
  });

  it("It should check the selectable property", function() {
    expect(_verticalLineStepSmallCircleTop.selectable).toEqual(false);
  });

  it("It should check the left property", function() {
    expect(_verticalLineStepSmallCircleTop.left).toEqual(1);
  });

  it("It should check the top property", function() {
    expect(_verticalLineStepSmallCircleTop.top).toEqual(5);
  });

});
