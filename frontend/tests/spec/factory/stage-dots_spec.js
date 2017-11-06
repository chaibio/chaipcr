describe("Testing stageDots, we click and drag stageDots to move stage", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageDots, _this;
  beforeEach(inject(function(stageDots) {
    _this = {
      parent: {
        editStageStatus: true
      },
      left: 100
    };

    _stageDots = new stageDots(_this);
  }));

  it("It should be a fabric Group with left: 100", function() {
    expect(_stageDots.left).toEqual(100);
  });

  it("It should be a fabric Group with top: 6", function() {
    expect(_stageDots.top).toEqual(6);
  });

  it("It should be a fabric Group with hasControls: false", function() {
    expect(_stageDots.hasControls).toBeFalsy();
  });

  it("It should be a fabric Group with width: 22", function() {
    expect(_stageDots.width).toEqual(22);
  });

  it("It should be a fabric Group with width: 22", function() {
    expect(_stageDots.width).toEqual(22);
  });

  it("It should be a fabric Group with height: 22", function() {
    expect(_stageDots.height).toEqual(22);
  });

  it("It should be a fabric Group with visible: true", function() {
    expect(_stageDots.visible).toBeTruthy(_this.parent.editStageStatus);
  });

  it("It should be a fabric Group with parent: _this", function() {
    expect(_stageDots.parent).toEqual(jasmine.objectContaining({
      parent: {
        editStageStatus: true
      },
      left: 100
    }));
  });

  it("It should be a fabric Group with name: moveStage", function() {
    expect(_stageDots.name).toEqual('moveStage');
  });

  it("It should be a fabric Group with lockMovementY: true", function() {
    expect(_stageDots.lockMovementY).toBeTruthy();
  });

  it("It should be a fabric Group with hasBorders: false", function() {
    expect(_stageDots.hasBorders).toBeFalsy('');
  });

  it("It should be a fabric Group with selectable: true", function() {
    expect(_stageDots.selectable).toBeTruthy();
  });

  it("It should be a fabric Group with backgroundColor: ''", function() {
    expect(_stageDots.backgroundColor).toEqual('');
  });

});
