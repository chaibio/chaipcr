describe("Testing stage graphics, Which creates all the graphics for the stage", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    mockCommonServices($provide);
  }));

  beforeEach(module('canvasApp'));

  var _stageGraphics;
  beforeEach(inject(function(stageGraphics) {
    _stageGraphics = stageGraphics;
  }));

  it("This should check addRoof method, called with a custom this object", function() {

    var checkVal = 100;
    var me = {
      myWidth: checkVal,
    };

    var sg = _stageGraphics.addRoof.call(me);
    expect(sg.roof.width).toEqual(checkVal);
  });

  it("This should check addRoof method x2 cordinate value", function() {

    var checkVal = 100;
    var me = {
      myWidth: checkVal,
    };

    var sg = _stageGraphics.addRoof.call(me);
    expect(sg.roof.x2).toEqual(checkVal);
  });

  it("This should check borderLeft method", function() {

    var sg = _stageGraphics.borderLeft();
    expect(sg.border).toEqual(jasmine.any(Object));
  });

  it("This should check borderLeft object, and its properties ", function() {

    var sg = _stageGraphics.borderLeft();
    expect(sg.border.top).toEqual(sg.border.y1);
  });

  it("This should check dotsOnStage method", function() {
    var me = {
      parent: {
        editStageStatus: false
      }
    };
    var sg = _stageGraphics.dotsOnStage.call(me);
    expect(sg.dots).toEqual(jasmine.any(Object));
  });

  it("This should check writeMyName method", function() {
    var me = {
      parent: {
        editStageStatus: false
      }
    };
    var sg = _stageGraphics.writeMyName.call(me);
    expect(me.stageNameGroup).toEqual(jasmine.any(Object));
  });

  it("This should check the createStageRect method", function() {

    sg = _stageGraphics.createStageRect();
    expect(sg.stageRect).toEqual(jasmine.any(Object));
  });

  it("This should check createStageGroup method, which returns stage conatiner", function() {

    var me = {
      left: 10,
      width: 100,
      parent: {
        editStageStatus: false
      }
    };
    _stageGraphics.addRoof.call(me);
    _stageGraphics.borderLeft.call(me);
    _stageGraphics.dotsOnStage.call(me);
    _stageGraphics.writeMyName.call(me);
    _stageGraphics.createStageRect.call(me);

    var sg = _stageGraphics.createStageGroup.call(me);
    expect(sg.stageGroup).toEqual(jasmine.any(Object));
  });

  it("This should check createStageGroup method, and if this method fills the stage object with all the sub components like roof, border ..", function() {

    var me = {
      left: 10,
      width: 100,
      parent: {
        editStageStatus: false
      }
    };
    _stageGraphics.addRoof.call(me);
    _stageGraphics.borderLeft.call(me);
    _stageGraphics.dotsOnStage.call(me);
    _stageGraphics.writeMyName.call(me);
    _stageGraphics.createStageRect.call(me);

    var sg = _stageGraphics.createStageGroup.call(me);
    expect(sg.roof).toEqual(jasmine.any(Object));
    expect(sg.border).toEqual(jasmine.any(Object));
    expect(sg.dots).toEqual(jasmine.any(Object));
    expect(sg.stageNameGroup).toEqual(jasmine.any(Object));
    expect(sg.stageRect).toEqual(jasmine.any(Object));
  });

});
