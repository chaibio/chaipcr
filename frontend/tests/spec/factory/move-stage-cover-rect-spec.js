describe("Testing moveStageCoverRect which is a wrapper for move-stage", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStageCoverRect;
  beforeEach(inject(function(moveStageCoverRect) {
    _moveStageCoverRect = new moveStageCoverRect();
  }));

  it("It should check fill property", function() {
    expect(_moveStageCoverRect.fill).toEqual(null);
  });

  it("It should check width property", function() {
    expect(_moveStageCoverRect.width).toEqual(135);
  });

  it("It should check left property", function() {
    expect(_moveStageCoverRect.left).toEqual(0);
  });

  it("It should check top property", function() {
    expect(_moveStageCoverRect.top).toEqual(0);
  });

  it("It should check height property", function() {
    expect(_moveStageCoverRect.height).toEqual(372);
  });

  it("It should check selectable property", function() {
    expect(_moveStageCoverRect.selectable).toEqual(false);
  });

  it("It should check rx property", function() {
    expect(_moveStageCoverRect.rx).toEqual(1);
  });

});
