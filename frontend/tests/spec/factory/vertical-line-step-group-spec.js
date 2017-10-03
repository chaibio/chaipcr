describe("Testing step vertical line's group", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _verticalLineStepGroup;

  beforeEach(inject(function(verticalLineStepGroup) {
    _verticalLineStepGroup =  new verticalLineStepGroup();
  }));

  it("It should test left property", function() {
    expect(_verticalLineStepGroup.left).toEqual(62);
  });

  it("It should test top property", function() {
    expect(_verticalLineStepGroup.top).toEqual(56);
  });

  it("It should test originX property", function() {
    expect(_verticalLineStepGroup.originX).toEqual('left');
  });

  it("It should test originY property", function() {
    expect(_verticalLineStepGroup.originY).toEqual('top');
  });

  it("It should test  selectable property", function() {
    expect(_verticalLineStepGroup. selectable).toEqual(true);
  });

  it("It should test lockMovementY property", function() {
    expect(_verticalLineStepGroup.lockMovementY).toEqual(true);
  });

  it("It should test hasControls property", function() {
    expect(_verticalLineStepGroup.hasControls).toEqual(false);
  });

  it("It should test hasBorders property", function() {
    expect(_verticalLineStepGroup.hasBorders).toEqual(false);
  });

  it("It should test name property", function() {
    expect(_verticalLineStepGroup.name).toEqual('vertica');
  });

  it("It should test visible property", function() {
    expect(_verticalLineStepGroup.visible).toEqual(false);
  });

});
