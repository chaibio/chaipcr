describe("Testing stege rect properties", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageRect, _constants;

  beforeEach(inject(function(stageRect, constants) {

    _stageRect = new stageRect();
    _constants = constants;
  }));

  it("Should check the width of the stageRect", function() {

    expect(_stageRect.width).toEqual(_constants.stepWidth);
  });

  it("Should check the left of the stageRect", function() {

    expect(_stageRect.left).toEqual(0);
  });

  it("Should check the top of the stageRect", function() {

    expect(_stageRect.top).toEqual(0);
  });

  it("Should check the fill of the stageRect", function() {

    expect(_stageRect.fill).toEqual("#FFB300");
  });

  it("Should check the height of the stageRect", function() {

    expect(_stageRect.height).toEqual(400);
  });

  it("Should check the selectable of the stageRect", function() {

    expect(_stageRect.selectable).toBeFalsy();
  });

});
