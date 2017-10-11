describe("Testing stepFooter", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stepFooter, step = {
      left: 500,
      parentStage: {
        parent: {
          editStageStatus: true
        }
      }
  };

  beforeEach(inject(function(stepFooter) {
    _stepFooter = new stepFooter(step);
  }));

  it("It should check left property", function() {
    expect(_stepFooter.left).toEqual(step.left + 16);
  });

  it("It should check top property", function() {
    expect(_stepFooter.top).toEqual(378);
  });

  it("It should check visible property", function() {
    expect(_stepFooter.visible).toEqual(step.parentStage.parent.editStageStatus);
  });

  it("It should check lockMovementY property", function() {
    expect(_stepFooter.lockMovementY).toBeTruthy();
  });

  it("It should check hasBorders property", function() {
    expect(_stepFooter.hasBorders).toBeFalsy();
  });

  it("It should check hasControls property", function() {
    expect(_stepFooter.hasControls).toBeFalsy();
  });

  it("It should check name property", function() {
    expect(_stepFooter.name).toEqual('moveStep');
  });

  it("It should check parent property", function() {
    expect(_stepFooter.parent).toEqual(jasmine.objectContaining({
      left: 500,
      parentStage: {
        parent: {
          editStageStatus: true
        }
      }
    }));
  });
});
