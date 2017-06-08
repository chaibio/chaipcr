describe("Testing step hit point", function() {

  beforeEach(module('ChaiBioTech'));
  beforeEach(module('canvasApp'));

  var _hitPoint, step = {
      left: 500,
    };
  beforeEach(inject(function(hitPoint) {
    _hitPoint = new hitPoint(step);
  }));

  it("It should chek the left property", function() {
    expect(_hitPoint.left).toEqual(step.left + 60);
  });

  it("It should chek the width property", function() {
    expect(_hitPoint.width).toEqual(10);
  });

  it("It should chek the height property", function() {
    expect(_hitPoint.height).toEqual(30);
  });

  it("It should chek the fill property", function() {
    expect(_hitPoint.fill).toEqual('');
  });

  it("It should chek the top property", function() {
    expect(_hitPoint.top).toEqual(335);
  });

  it("It should chek the selectable property", function() {
    expect(_hitPoint.selectable).toBeFalsy();
  });

  it("It should chek the name property", function() {
    expect(_hitPoint.name).toEqual('hitPoint');
  });
});
