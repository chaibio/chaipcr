describe("Testing Group service", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  var group, properties, circle, line;

  beforeEach(inject(function(Group, Circle, Line) {

    circle = Circle;
    group = Group;
    line = Line;
    properties = {
      originX: "left", originY: "top", selectable: true, top : 8, left: 100
    };

  }));

  it("This should create a fabric Group", function() {
    var newCircle = circle.create();
    var newLine = line.create();
    var newGroup =  group.create([newCircle, newLine], properties);
    expect(newGroup.left).toEqual(properties.left);
  });
});
