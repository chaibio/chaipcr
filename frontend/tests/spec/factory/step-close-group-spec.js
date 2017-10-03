describe("Testing closeGroup", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _closeGroup, shadowCloseGroup;
  step = {
    left: 100,
    $scope: {
      exp_completed: false
    },
    parentStage: {
      parent: {
        editStageStatus: false
      }
    }
  };

  beforeEach(inject(function(closeGroup) {
    _closeGroup = new closeGroup(step);
    shadowCloseGroup = closeGroup;
  }));

  it("It should check the left value of the group", function() {
    expect(_closeGroup.left).toEqual(step.left + 116);
  });

  it("It should check the hasBorders value of the group", function() {
    expect(_closeGroup.hasBorders).toBeFalsy();
  });

  it("It should check the hasControls value of the group", function() {
    expect(_closeGroup.hasControls).toBeFalsy();
  });

  it("It should check the lockMovementY value of the group", function() {
    expect(_closeGroup.lockMovementY).toBeTruthy();
  });

  it("It should check the lockMovementX value of the group", function() {
    expect(_closeGroup.lockMovementX).toBeTruthy();
  });

  it("It should check the top value of the group", function() {
    expect(_closeGroup.top).toEqual(86);
  });

  it("It should check the opacity value of the group", function() {
    expect(_closeGroup.opacity).toEqual(0);
    step = {
      left: 100,
      $scope: {
        exp_completed: false
      },
      parentStage: {
        parent: {
          editStageStatus: true
        }
      }
    };

    _closeGroup = new shadowCloseGroup(step);
    expect(_closeGroup.opacity).toEqual(1);
  });

  it("It should check the name of the group", function() {
    expect(_closeGroup.name).toEqual('deleteStepButton');
  });

  it("It should check the evented value of the group", function() {

    step = {
      left: 100,
      $scope: {
        exp_completed: false
      },
      parentStage: {
        parent: {
          editStageStatus: true
        }
      }
    };

    _closeGroup = new shadowCloseGroup(step);
    expect(_closeGroup.evented).toBeTruthy();
  });


});
