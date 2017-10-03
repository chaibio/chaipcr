describe("Testing Circle service", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  var circle, properties;
  beforeEach(inject(function(Circle) {
    circle = Circle;
    properties = {
      radius: 6, stroke: 'rgb(166, 122, 40)', originX: "center", originY: "center",
      fill: '#ffb400', strokeWidth: 2, selectable: false, name: "newClose",
    };
  }));

  it("This should create a fabric Circle", function() {
    var newCircle = circle.create(properties);
    expect(newCircle.radius).toEqual(properties.radius);
  });
});
