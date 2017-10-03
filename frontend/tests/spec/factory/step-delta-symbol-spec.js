describe("Testing delta symbol", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _deltaSymbol;
  beforeEach(inject(function(deltaSymbol) {
    _deltaSymbol = new deltaSymbol();
  }));

  it("It should check the text property", function() {
    expect(_deltaSymbol.text).toEqual('Δ');
  });

  it("It should check the fill property", function() {
    expect(_deltaSymbol.fill).toEqual('white');
  });

  it("It should check the fontSize property", function() {
    expect(_deltaSymbol.fontSize).toEqual(14);
  });

  it("It should check the top property", function() {
    expect(_deltaSymbol.top).toEqual(338);
  });

  it("It should check the left property", function() {
    expect(_deltaSymbol.left).toEqual(10);
  });

  it("It should check the fontFamily property", function() {
    expect(_deltaSymbol.fontFamily).toEqual('dinot');
  });

  it("It should check the selectable property", function() {
    expect(_deltaSymbol.selectable).toBeFalsy();
  });

  it("It should check the fontWeight property", function() {
    expect(_deltaSymbol.fontWeight).toEqual('bold');
  });

  it("It should check the visible property", function() {
    expect(_deltaSymbol.visible).toBeFalsy();
  });

  it("It should check the shadow property", function() {
    expect(_deltaSymbol.shadow.offsetX).toEqual(5);
    expect(_deltaSymbol.shadow.offsetY).toEqual(5);
    expect(_deltaSymbol.shadow.blur).toEqual(7);
    expect(_deltaSymbol.shadow.color).toEqual('rgba(0,0,0,0.4)');
  });

});
