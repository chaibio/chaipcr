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

  it("It should check stageHitPointLeft fill, fill should be '', so that we dont see hitPoints.", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLeft.fill).toEqual('');
  });

  it("It should check stageHitPointLeft top", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLeft.top).toEqual(10);
  });

  it("It should check stageHitPointLeft selectable: false", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLeft.selectable).toBeFalsy();
  });

  it("It should check stageHitPointRight left", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointRight.left).toEqual((prop.left + prop.width) - 20);
  });

  it("It should check stageHitPointRight fill, fill should be '', so that we dont see hitPoints.", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointRight.fill).toEqual('');
  });

  it("It should check stageHitPointRight top", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointRight.top).toEqual(10);
  });

  it("It should check stageHitPointRight selectable", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointRight.selectable).toBeFalsy();
  });

  it("It should check stageHitPointLowerLeft left", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLowerLeft.left).toEqual(prop.left + 10);
  });

  it("It should check stageHitPointLowerLeft fill, fill should be '', so that we dont see hitPoints.", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLowerLeft.fill).toEqual('');
  });

  it("It should check stageHitPointLowerLeft top", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLowerLeft.top).toEqual(340);
  });

  it("It should check stageHitPointLowerLeft selectable", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLowerLeft.selectable).toBeFalsy();
  });

  it("It should check stageHitPointLowerRight left", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLowerRight.left).toEqual((prop.left + prop.width) - 20);
  });

  it("It should check stageHitPointLowerRight fill, fill should be '', so that we dont see hitPoints.", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLowerRight.fill).toEqual('');
  });

  it("It should check stageHitPointLowerRight top", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLowerRight.top).toEqual(340);
  });

  it("It should check stageHitPointLowerRight selectable", function() {
    var allHitPoints = _hitPoints.createAllHitPoints(prop);
    expect(allHitPoints.stageHitPointLowerRight.selectable).toBeFalsy();
  });
});
