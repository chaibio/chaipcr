describe("Testing the delta group", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _deltaGroup, step = {};

  beforeEach(inject(function(deltaGroup) {
    _deltaGroup = new deltaGroup(step);
  }));

  it("It should check top property", function() {
    expect(_deltaGroup.top).toEqual(338);
  });

  it("It should check left property", function() {
    expect(_deltaGroup.left).toEqual(24);
  });

  it("It should check visible property", function() {
    expect(_deltaGroup.visible).toBeFalsy();
  });

});
