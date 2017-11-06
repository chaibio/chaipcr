describe("Testing StagePositionService", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _StagePositionService, stages;

  beforeEach(inject(function(StagePositionService) {
    _StagePositionService = StagePositionService;

  }));

  it("It should test init method", function() {

    _StagePositionService.init("Test");
    expect(_StagePositionService.allStages).toEqual("Test");
  });

  it("It should test getPositionObject method allStages == null", function() {

    _StagePositionService.allStages = null;
    var rValue = _StagePositionService.getPositionObject();
    expect(rValue).toEqual(null);
  });

  it("It should test getPositionObject when allStages has data", function() {

    _StagePositionService.allStages = [
      {
        left: 10,
        myWidth: 15,
      },
      {
        left: 25,
        myWidth: 15
      }
    ];

    _StagePositionService.getPositionObject();

    expect(_StagePositionService.allPositions).toEqual(jasmine.any(Array));
    expect(_StagePositionService.allPositions[0]).toEqual(jasmine.arrayContaining(
      [
        _StagePositionService.allStages[0].left,
        _StagePositionService.allStages[0].left + (_StagePositionService.allStages[0].myWidth) / 2,
        _StagePositionService.allStages[0].left + _StagePositionService.allStages[0].myWidth
      ]
    ));
  });

  it("It should test getAllVoidSpaces method allStages == null", function() {

    _StagePositionService.allStages = null;
    var rValue = _StagePositionService.getAllVoidSpaces();
    expect(rValue).toEqual(null);
  });

  it("It should test getAllVoidSpaces when allStages has data", function() {

    _StagePositionService.allStages = [
      {
        left: 10,
        myWidth: 15,
        previousStage: {
          left: 0,
        },
        nextStage: {
          left: 10
        }
      },
      {
        left: 25,
        myWidth: 15,
        previousStage: {
          left: 10,
          myWidth: 15,
        },
        nextStage: {
          left: 40,
          myWidth: 15
        }
      }
    ];

    _StagePositionService.getAllVoidSpaces();

    expect(_StagePositionService.allVoidSpaces).toEqual(jasmine.any(Array));
    expect(_StagePositionService.allVoidSpaces[0]).toEqual(jasmine.arrayContaining(
      [
        33,
        _StagePositionService.allStages[0].left
      ]
    ));
  });
});
