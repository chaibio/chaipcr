describe("Testing step closeLine", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _closeLine,
    shadowCloseLine;
  beforeEach(inject(function(closeLine) {
    _closeLine = new closeLine();
    shadowCloseLine = closeLine;
  }));

  it("It should check closeLine stroke ", function() {
    expect(_closeLine.stroke).toEqual('rgb(166, 122, 40)');
  });

  it("It should check the angle of closeLine if provided", function() {
    var prop = {
      stroke: 'rgb(166, 122, 40)',
      angle: 90,
      originX: 'center',
      originY: 'center',
    };

    _closeLine = new shadowCloseLine(prop);

    expect(_closeLine.angle).toEqual(90);
  });




});
