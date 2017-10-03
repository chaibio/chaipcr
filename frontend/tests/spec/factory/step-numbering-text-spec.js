describe("Testing numberingText", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _numberingText, step = {
    left: 1000,
    model: {
      ramp: {
        rate: 10
      }
    }
  }, type = "something else", shadowNumberingText;

  beforeEach(inject(function(numberingText) {
    _numberingText = new numberingText(type);
    shadowNumberingText = numberingText;
  }));

  it("It should check the text property", function() {
    expect(_numberingText.text).toEqual("wow");
  });

  it("It should check the fill property", function() {
    expect(_numberingText.fill).toEqual("white");
  });

  it("It should check the fontSize property", function() {
    expect(_numberingText.fontSize).toEqual(12);
  });

  it("It should check the top property", function() {
    expect(_numberingText.top).toEqual(7);
  });

  it("It should check the fontFamily property", function() {
    expect(_numberingText.fontFamily).toEqual('dinot');
  });

  it("It should check the selectable property", function() {
    expect(_numberingText.selectable).toBeFalsy();
  });

  it("It should check the left property", function() {
    type = "current";
    _numberingText = new shadowNumberingText(type);
    expect(_numberingText.left).toEqual(-1);
  });

  it("It should check the fontFamily property", function() {
    type = "current";
    _numberingText = new shadowNumberingText(type);
    expect(_numberingText.fontFamily).toEqual('dinot-bold');
  });

});
