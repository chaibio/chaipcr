describe("Testing StepPositionService", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));

  var _StepPositionService;
  beforeEach(inject(function(StepPositionService) {
    _StepPositionService = StepPositionService;
  }));

  it("It should test the init method", function() {

    _StepPositionService.init("test");
    expect(_StepPositionService.allSteps).toEqual("test");
  });

  it("It should test getPositionObject method when, allSteps is null", function() {

    _StepPositionService.allSteps = null;
    var rValue = _StepPositionService.getPositionObject();
    expect(rValue).toEqual(null);
  });

  it("It should test getPositionObject method when, allSteps is not null", function() {
    _StepPositionService.allSteps = [];
    var steps = [
      {
        left: 100,
        myWidth: 30,
      }
    ];
    var allPositions = _StepPositionService.getPositionObject(steps);
    expect(allPositions).toEqual(jasmine.any(Array));
    expect(allPositions[0]).toEqual(jasmine.arrayContaining([
      steps[0].left,
      steps[0].left + (steps[0].myWidth / 2),
      steps[0].left + steps[0].myWidth
    ]));
  });

});
