describe("Testing stepGraphics", function() {

  beforeEach(module('ChaiBioTech'));
  beforeEach(module('canvasApp'));

  var _stepGraphics;
  beforeEach(inject(function(stepGraphics) {
    _stepGraphics = stepGraphics;
  }));

  it("It should check the addName method", function() {

    var name = "chai";
    var step = {
      stepNameText: name
    };

    var sg = _stepGraphics.addName.call(step);
    expect(sg.stepName.text).toEqual(name);
  });

  it("It should check the stepFooter method, calling this method should give dots object", function() {

    var step = {
      parentStage: {
        parent: {
          editStageStatus: true
        }
      }
    };
      var sg = _stepGraphics.stepFooter.call(step);
      expect(sg.dots).toEqual(jasmine.any(Object));
  });

  it("It should check the deleteButton method, calling this method should give closeImage group object", function() {

    var step = {
      parentStage: {
        parent: {
          editStageStatus: true
        }
      },
      $scope: {
        exp_completed: true
      }
    };
      var sg = _stepGraphics.deleteButton.call(step);
      expect(sg.closeImage).toEqual(jasmine.any(Object));
  });

});
