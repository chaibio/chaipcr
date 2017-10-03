describe("Testing the background of dots in the top of the stage, which is used to drag the stage", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageDotsBackground;
  beforeEach(inject(function(stageDotsBackground) {

    _stageDotsBackground = new stageDotsBackground();
  }));

  it("It should be a fabric Rect object with width: 15", function() {
    expect(_stageDotsBackground.width).toEqual(15);
  });

  it("It should be a fabric Rect object with fill: #FFB300", function() {
    expect(_stageDotsBackground.fill).toEqual('#FFB300');
  });

  it("It should be a fabric Rect object with left: 0", function() {
    expect(_stageDotsBackground.left).toEqual(0);
  });

  it("It should be a fabric Rect object with top: -2", function() {
    expect(_stageDotsBackground.top).toEqual(-2);
  });

  it("It should be a fabric Rect object with selectable: false", function() {
    expect(_stageDotsBackground.selectable).toBeFalsy();
  });

  it("It should be a fabric Rect object with selectable: false", function() {
    expect(_stageDotsBackground.selectable).toBeFalsy();
  });
});
