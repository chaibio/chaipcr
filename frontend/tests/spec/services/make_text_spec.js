describe("Testing Text service", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  var text, properties, displayText;

  beforeEach(inject(function(Text) {
    text = Text;
    displayText = "Chaibio";
    properties = {
      fill: 'white', fontWeight: "400",  fontSize: 12,   fontFamily: "dinot-bold",
      originX: "left", originY: "top", selectable: true, left: 0
    };
  }));

  it("This should create a fabric Text", function() {
    var newText = text.create(displayText, properties);
    expect(newText.text).toEqual(displayText);
    expect(newText.fill).toEqual(properties.fill);
    expect(newText.fontWeight).toEqual(properties.fontWeight);
  });
});
