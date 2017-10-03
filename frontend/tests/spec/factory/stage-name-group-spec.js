describe("Testing stage name group, which contains all the components like stageCaption and stageName", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageNameGroup, stage, originalStageNameGroup;
  beforeEach(inject(function(stageNameGroup) {
    stage = {
      parent: {
        editStageStatus: true,
      }
    };
    originalStageNameGroup = stageNameGroup;
    _stageNameGroup = new stageNameGroup(stage);

  }));

  it("It should check the left property of the group created", function() {
    expect(_stageNameGroup.left).toEqual(26); //because editStageStatus: true
  });

  it("It should check the left property when editStageStatus is false", function() {

    stage = {
      parent: {
        editStageStatus: false,
      }
    };
    _stageNameGroup = new originalStageNameGroup(stage);
    expect(_stageNameGroup.left).toEqual(1);
  });

  it("It should check the moved variable values, for editStageStatus: true it should be Right", function() {
    expect(_stageNameGroup.moved).toEqual('right');
  });

  it("It should check the moved, for editStageStatus: false, it should be false", function() {
    stage = {
      parent: {
        editStageStatus: false,
      }
    };
    _stageNameGroup = new originalStageNameGroup(stage);
    expect(_stageNameGroup.moved).toBeFalsy();
  });

  it("It should check the top property", function() {
    expect(_stageNameGroup.top).toEqual(8);
  });

  it("It should check the selectable property", function() {
    expect(_stageNameGroup.selectable).toBeTruthy();
  });
});
