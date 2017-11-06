describe("Testing the stage roof properties", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageRoof;
  beforeEach(inject(function(stageRoof) {

    _stageRoof = new stageRoof(100);
  }));

  it("Should check the stroke property", function() {

    expect(_stageRoof.stroke).toEqual('white');
  });

  it("Should check the strokeWidth property", function() {

    expect(_stageRoof.strokeWidth).toEqual(2);
  });

  it("Should check the left property", function() {

    expect(_stageRoof.left).toEqual(0);
  });

  it("Should check the selectable", function() {

    expect(_stageRoof.selectable).toBeFalsy();
  });

  it("Should check the width property, which we passed along new stageRoof(100);", function() {

    expect(_stageRoof.width).toEqual(100);
  });

  it("Should check the x1", function() {
    expect(_stageRoof.x1).toEqual(0);
  });

  it("Should check the x1", function() {
    expect(_stageRoof.y1).toEqual(24);
  });

  it("Should check the x1", function() {
    expect(_stageRoof.x2).toEqual(100);
  });

  it("Should check the x1", function() {
    expect(_stageRoof.y2).toEqual(24);
  });

});
