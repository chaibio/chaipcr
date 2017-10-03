describe("Testing moveStepIndicator", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _moveStepIndicator;

  beforeEach(inject(function(moveStepIndicator, Image) {

    var obj = {
      imageobjects: {
        "drag-footer-image.png": Image.create()
      }
    };
    _moveStepIndicator = new moveStepIndicator(obj);

  }));

  it("It should test name property", function() {
    expect(_moveStepIndicator.name).toEqual("dragStepGroup");
  });

  it("It should test temperatureText", function() {
    expect(_moveStepIndicator.temperatureText).toEqual(jasmine.any(Object));
  });

  it("It should test holdTimeText", function() {
    expect(_moveStepIndicator.holdTimeText).toEqual(jasmine.any(Object));
  });

  it("It should test indexText", function() {
    expect(_moveStepIndicator.indexText).toEqual(jasmine.any(Object));
  });

  it("It should test placeText", function() {
    expect(_moveStepIndicator.placeText).toEqual(jasmine.any(Object));
  });


});
