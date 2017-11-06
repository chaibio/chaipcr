describe("Testing stageGroup which is the container of the whole stage.", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageGroup, _stageContents = [], left = 40;
  beforeEach(inject(function(stageGroup) {
    _stageGroup = new stageGroup(_stageContents, left);
  }));

  it("It should be a fabric Group object with left: 40", function() {
    expect(_stageGroup.left).toEqual(40);
  });

  it("It should be a fabric Group object with top: 0", function() {
    expect(_stageGroup.top).toEqual(0);
  });

  it("It should be a fabric Group object with selectable: false", function() {
    expect(_stageGroup.selectable).toBeFalsy();
  });

  it("It should be a fabric Group object with hasControls: false", function() {
    expect(_stageGroup.hasControls).toBeFalsy();
  });
});
