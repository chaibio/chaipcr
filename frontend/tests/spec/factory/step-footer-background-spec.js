describe("Testing stepFooterBackground", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stepFooterBackground;
  beforeEach(inject(function(stepFooterBackground) {
    //width: 94, height: 14, fill: '#ffb400', selectable: false, name: "backgroundRect",
    _stepFooterBackground = new stepFooterBackground();
  }));

  it("It should check width property", function() {
    expect(_stepFooterBackground.width).toEqual(94);
  });

  it("It should check height property", function() {
    expect(_stepFooterBackground.height).toEqual(14);
  });

  it("It should check fill property", function() {
    expect(_stepFooterBackground.fill).toEqual('#ffb400');
  });

  it("It should check selectable property", function() {
    expect(_stepFooterBackground.selectable).toBeFalsy();
  });

  it("It should check name property", function() {
    expect(_stepFooterBackground.name).toEqual('backgroundRect');
  });


});
