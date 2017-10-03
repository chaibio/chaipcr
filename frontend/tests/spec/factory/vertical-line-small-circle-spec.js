describe("Testing vertica line's small circle at the end of the line", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _verticalLineSmallCirclep;

  beforeEach(inject(function(verticalLineSmallCircle) {
    _verticalLineSmallCircle =  new verticalLineSmallCircle();
  }));

  it("It should check the radius property", function() {
    expect(_verticalLineSmallCircle.radius).toEqual(6);
  });

  it("It should check the fill property", function() {
    expect(_verticalLineSmallCircle.fill).toEqual('white');
  });

  it("It should check the stroke property", function() {
    expect(_verticalLineSmallCircle.stroke).toEqual('black');
  });

  it("It should check the strokeWidth property", function() {
    expect(_verticalLineSmallCircle.strokeWidth).toEqual(2);
  });

  it("It should check the selectable property", function() {
    expect(_verticalLineSmallCircle.selectable).toEqual(false);
  });

  it("It should check the left property", function() {
    expect(_verticalLineSmallCircle.left).toEqual(69);
  });

  it("It should check the top property", function() {
    expect(_verticalLineSmallCircle.top).toEqual(390);
  });

});
