describe("Testing stage hit point, which are used to detect the move stage action", function() {

  beforeEach(module('ChaiBioTech'));
  beforeEach(module('canvasApp'));

  var _hitPoints, prop;
  beforeEach(inject(function(hitPoints) {
    _hitPoints = hitPoints;
    prop = {
      left: 100,
      width: 110
    };
  }));

  it("It should return an object with all the hitPoints in it, {stageHitPointLeft, stageHitPointRight, stageHitPointLowerLeft, stageHitPointLowerRight}", function() {

    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints).toEqual(jasmine.objectContaining({
      stageHitPointLeft: jasmine.any(Object),
      stageHitPointRight: jasmine.any(Object),
      stageHitPointLowerLeft: jasmine.any(Object),
      stageHitPointLowerRight: jasmine.any(Object)
    }));
  });

  it("It should check stageHitPointLeft left", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLeft.left).toEqual(prop.left + 10);
  });

  it("It should check stageHitPointLeft top", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLeft.top).toEqual(10);
  });

  it("It should check stageHitPointLeft selectable: false", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLeft.selectable).toBeFalsy();
  });

});
