describe("Testing step vertical line's small circle at the end of the line", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _verticalLineStepSmallCircle;

  beforeEach(inject(function(verticalLineStepSmallCircle) {
    _verticalLineStepSmallCircle =  new verticalLineStepSmallCircle();
  }));

  it("It should check the radius property", function() {
    expect(_verticalLineStepSmallCircle.radius).toEqual(6);
  });

  it("It should check the fill property", function() {
    expect(_verticalLineStepSmallCircle.fill).toEqual('#FFB300');
  });

  it("It should check the originX property", function() {
    expect(_verticalLineStepSmallCircle.originX).toEqual('center');
  });

  it("It should check the originY property", function() {
    expect(_verticalLineStepSmallCircle.originY).toEqual('center');
  });

  it("It should check the selectable property", function() {
    expect(_verticalLineStepSmallCircle.selectable).toEqual(false);
  });

  it("It should check the left property", function() {
    expect(_verticalLineStepSmallCircle.left).toEqual(1);
  });

  it("It should check the top property", function() {
    expect(_verticalLineStepSmallCircle.top).toEqual(269);
  });

  it("It should check the stroke property", function() {
    expect(_verticalLineStepSmallCircle.stroke).toEqual('black');
  });

  it("It should check the strokeWidth property", function() {
    expect(_verticalLineStepSmallCircle.strokeWidth).toEqual(3);
  });
  it("It should check the visible property", function() {
    expect(_verticalLineStepSmallCircle.visible).toEqual(true);
  });

});
