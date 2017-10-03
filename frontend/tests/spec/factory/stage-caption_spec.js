describe("Testing stage caption", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageCaption;
  beforeEach(inject(function(stageCaption) {
    _stageCaption = new stageCaption();
  }));

  it("It should be a fabric Text object with fill: white", function() {
    expect(_stageCaption.fill).toEqual("white");
  });

  it("It should be a fabric Text object with fontWeight: 400", function() {
    expect(_stageCaption.fontWeight).toEqual("400");
  });

  it("It should be a fabric Text object with fontSize: 12", function() {
    expect(_stageCaption.fontSize).toEqual(12);
  });

  it("It should be a fabric Text object with fontFamily: dinot-bold", function() {
    expect(_stageCaption.fontFamily).toEqual("dinot-bold");
  });

  it("It should be a fabric Text object with selectable: true", function() {
    expect(_stageCaption.selectable).toBe(true);
  });

  it("It should be a fabric Text object with left: 0", function() {
    expect(_stageCaption.left).toEqual(0);
  });


});
