describe("Testing move-stage-indicator-group", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStageIndicatorGroup;
  beforeEach(inject(function(moveStageIndicatorGroup, moveStageName, moveStageType, moveStageRectangle) {

    _moveStageIndicatorGroup = new moveStageIndicatorGroup([
      new moveStageName(),
      new moveStageType(),
      new moveStageRectangle(),
    ]);
  }));

  it("It should check the left property", function() {
    expect(_moveStageIndicatorGroup.left).toEqual(38);
  });

  it("It should check the top property", function() {
    expect(_moveStageIndicatorGroup.top).toEqual(0);
  });

  it("It should check the height property", function() {
    expect(_moveStageIndicatorGroup.height).toEqual(372);
  });

  it("It should check the width property", function() {
    expect(_moveStageIndicatorGroup.width).toEqual(135);
  });

  it("It should check the selectable property", function() {
    expect(_moveStageIndicatorGroup.selectable).toEqual(true);
  });

  it("It should check the lockMovementY property", function() {
    expect(_moveStageIndicatorGroup.lockMovementY).toEqual(true);
  });

  it("It should check the hasControls property", function() {
    expect(_moveStageIndicatorGroup.hasControls).toEqual(false);
  });

  it("It should check the visible property", function() {
    expect(_moveStageIndicatorGroup.visible).toEqual(false);
  });

  it("It should check the lockMovementY property", function() {
    expect(_moveStageIndicatorGroup.hasBorders).toEqual(false);
  });

  it("It should check the lockMovementY property", function() {
    expect(_moveStageIndicatorGroup.name).toEqual("dragStageGroup");
  });

});
