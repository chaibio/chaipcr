describe("Testing stepDataGroupService", function() {

  var _stepDataGroupService, _stepDataGroup, _stepTemperature, _stepHoldTime;

  beforeEach(function() {

    module('ChaiBioTech', function($provide) {
      mockCommonServices($provide);
    });

    inject(function($injector) {
      _stepDataGroup = $injector.get('stepDataGroup');
      _stepTemperature = $injector.get("stepTemperature");
      _stepHoldTime = $injector.get("stepHoldTime");
      _stepDataGroupService = $injector.get('stepDataGroupService');
    });

  });

  it("It should test newStepDataGroup method", function() {

    var circle = {
      model: {
        temperature: 34,
        hold_time: 100
      },
    };

    var $scope = {

    };

    _stepDataGroupService.newStepDataGroup(circle, $scope);

    expect(circle.stepDataGroup).toEqual(jasmine.any(Object));
  });

  it("It should test reCreateNewStepDataGroup method", function() {

    var circle = {

      canvas: {
        remove: function() {},
        add: function() {},
        renderAll: function() {}
      }
    };
    var $scope = {

    };

    spyOn(_stepDataGroupService, "newStepDataGroup").and.returnValue(true);
    spyOn(circle.canvas, "remove");
    spyOn(circle.canvas, "add");
    spyOn(circle.canvas, "renderAll");

    _stepDataGroupService.reCreateNewStepDataGroup(circle, $scope);

    expect(_stepDataGroupService.newStepDataGroup).toHaveBeenCalled();
    expect(circle.canvas.remove).toHaveBeenCalled();
    expect(circle.canvas.add).toHaveBeenCalled();
    expect(circle.canvas.renderAll).toHaveBeenCalled();

  });
});
