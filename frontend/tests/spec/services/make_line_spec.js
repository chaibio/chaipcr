describe("Testing Line service", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  var line, properties, cordinates;

  beforeEach(inject(function(Line) {
    line = Line;
    properties = {
        stroke: 'white', strokeWidth: 2, selectable: false, left: 0
      };
    cordinates = [0, 24, (this.myWidth), 24];
  }));

  it("This should create a fabric Line", function() {
    var newLine = line.create(cordinates, properties);
    expect(newLine.stroke).toEqual(properties.stroke);
    expect(newLine.strokeWidth).toEqual(properties.strokeWidth);
  });
});
