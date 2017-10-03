describe("Texting step's closeCircle", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _closeCircle;
  beforeEach(inject(function(closeCircle) {
    _closeCircle = new closeCircle();
  }));

  it("Should check the radius of closeCircle", function() {
    expect(_closeCircle.radius).toEqual(6);
  });

  it("Should check the radius of stroke", function() {
    expect(_closeCircle.stroke).toEqual('rgb(166, 122, 40)');
  });

  it("Should check the fill of closeCircle", function() {
    expect(_closeCircle.fill).toEqual('#ffb400');
  });

  it("Should check the strokeWidth of closeCircle", function() {
    expect(_closeCircle.strokeWidth).toEqual(2);
  });

  it("Should check the selectable of closeCircle", function() {
    expect(_closeCircle.selectable).toBeFalsy();
  });

  it("Should check the name of closeCircle", function() {
    expect(_closeCircle.name).toEqual('newClose');
  });
});
