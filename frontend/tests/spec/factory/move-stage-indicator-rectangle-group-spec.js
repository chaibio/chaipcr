describe("Testing stage-indicator-group", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStageIndicatorRectangleGroup;
  beforeEach(inject(function(moveStageIndicatorRectangleGroup, moveStageName, moveStageType, moveStageRectangle) {

    _moveStageIndicatorRectangleGroup = new moveStageIndicatorRectangleGroup([
      new moveStageName(),
      new moveStageType(),
      new moveStageRectangle(),
    ]);
  }));

  it("It should check left property", function() {
    expect(_moveStageIndicatorRectangleGroup.left).toEqual(0);
  });

  it("It should check top property", function() {
    expect(_moveStageIndicatorRectangleGroup.top).toEqual(0);
  });

  it("It should check height property", function() {
    expect(_moveStageIndicatorRectangleGroup.height).toEqual(72);
  });

  it("It should check selectable property", function() {
    expect(_moveStageIndicatorRectangleGroup.selectable).toEqual(true);
  });

  it("It should check lockMovementY property", function() {
    expect(_moveStageIndicatorRectangleGroup.lockMovementY).toEqual(true);
  });

  it("It should check hasControls property", function() {
    expect(_moveStageIndicatorRectangleGroup.hasControls).toEqual(false);
  });

  it("It should check visible property", function() {
    expect(_moveStageIndicatorRectangleGroup.visible).toEqual(true);
  });

  it("It should check hasBorders property", function() {
    expect(_moveStageIndicatorRectangleGroup.hasBorders).toEqual(false);
  });

  it("It should check name property", function() {
    expect(_moveStageIndicatorRectangleGroup.name).toEqual("dragStageRect");
  });



});
