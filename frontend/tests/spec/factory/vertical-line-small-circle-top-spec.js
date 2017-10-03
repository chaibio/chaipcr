describe("Testing small circle in vertical line group", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _verticalLineSmallCircleTop;

  beforeEach(inject(function(verticalLineSmallCircleTop) {
    _verticalLineSmallCircleTop =  new verticalLineSmallCircleTop();
  }));

  it("It should test fill property", function() {
    expect(_verticalLineSmallCircleTop.fill).toEqual('#FFB300');
  });

  it("It should test radius property", function() {
    expect(_verticalLineSmallCircleTop.radius).toEqual(6);
  });

  it("It should test strokeWidth property", function() {
    expect(_verticalLineSmallCircleTop.strokeWidth).toEqual(3);
  });

  it("It should test selectable property", function() {
    expect(_verticalLineSmallCircleTop.selectable).toEqual(false);
  });

  it("It should test stroke property", function() {
    expect(_verticalLineSmallCircleTop.stroke).toEqual('black');
  });

  it("It should test left property", function() {
    expect(_verticalLineSmallCircleTop.left).toEqual(69);
  });

  it("It should test top property", function() {
    expect(_verticalLineSmallCircleTop.top).toEqual(64);
  });
});
