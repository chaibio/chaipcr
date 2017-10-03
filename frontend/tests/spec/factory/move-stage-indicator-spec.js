describe("Testing move-stage-indicator", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStageIndicator;

  beforeEach(inject(function(moveStageIndicator) {

    var me = {
    };
    _moveStageIndicator = new moveStageIndicator(me);
  }));

  it("It should check if moveStageIndicator has stageName", function() {
    expect(_moveStageIndicator.stageName).toEqual(jasmine.any(Object));
  });

  it("It should check if moveStageIndicator has stageType", function() {
    expect(_moveStageIndicator.stageType).toEqual(jasmine.any(Object));
  });

  it("It should check if moveStageIndicator.stageType text property", function() {
    expect(_moveStageIndicator.stageType.text).toEqual("HOLDING");
  });

  it("It should check if moveStageIndicator.stageName text property", function() {
    expect(_moveStageIndicator.stageName.text).toEqual("STAGE 2");
  });

});
