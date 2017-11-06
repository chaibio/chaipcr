describe("Testing Rectangle service", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));
  
  var rectangle, properties;

  beforeEach(inject(function(Rectangle) {
    rectangle = Rectangle;
    properties = {
      width: 30, height: 10, fill: '', left: 50, top: 10, selectable: false, name: "rightPointerDetector",
      originX: 'left', originY: 'top',
    };
  }));

  it("This should create a fabric Rectangle", function() {
    var newRectangle = rectangle.create(properties);
    expect(newRectangle.width).toEqual(properties.width);
    expect(newRectangle.height).toEqual(properties.height);
    expect(newRectangle.left).toEqual(properties.left);
  });
});
