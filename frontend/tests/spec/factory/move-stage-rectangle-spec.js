describe("Testing move-stage-rectangle", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));

  beforeEach(module('canvasApp'));

  var _moveStageRectangler;

  beforeEach(inject(function(moveStageRectangle) {

    _moveStageRectangle = new moveStageRectangle();
  }));

  it("It should check fill property", function() {
    expect(_moveStageRectangle.fill).toEqual("white");
  });

  it("It should check width property", function() {
    expect(_moveStageRectangle.width).toEqual(135);
  });

  it("It should check left property", function() {
    expect(_moveStageRectangle.left).toEqual(0);
  });

  it("It should check height property", function() {
    expect(_moveStageRectangle.height).toEqual(58);
  });

  it("It should check selectable property", function() {
    expect(_moveStageRectangle.selectable).toEqual(false);
  });

  it("It should check name property", function() {
    expect(_moveStageRectangle.name).toEqual("move_stage_rectangle");
  });

  it("It should check rx property", function() {
    expect(_moveStageRectangle.rx).toEqual(1);
  });
});
