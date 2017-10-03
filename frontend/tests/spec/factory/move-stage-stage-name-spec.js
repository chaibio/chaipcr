describe("Testing move-stage-name", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide)
  }));

  beforeEach(module('canvasApp'));

  var _moveStageName;

  beforeEach(inject(function(moveStageName) {

    _moveStageName = new moveStageName();
  }));

  it("It should check text property", function() {
    expect(_moveStageName.text).toEqual("STAGE 2");
  });

  it("It should check fill property", function() {
    expect(_moveStageName.fill).toEqual("black");
  });

  it("It should check fontSize property", function() {
    expect(_moveStageName.fontSize).toEqual(12);
  });

  it("It should check selectable property", function() {
    expect(_moveStageName.selectable).toEqual(false);
  });

  it("It should check top property", function() {
    expect(_moveStageName.top).toEqual(15);
  });

  it("It should check left property", function() {
    expect(_moveStageName.left).toEqual(35);
  });


  it("It should check fontFamily property", function() {
    expect(_moveStageName.fontFamily).toEqual('dinot-bold');
  });

});
