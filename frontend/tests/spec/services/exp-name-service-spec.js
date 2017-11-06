describe("Testing expName method", function() {

  var _$rootScope, _expName;

  beforeEach(function() {

    module('ChaiBioTech', function($provide) {
      mockCommonServices($provide)
    });

    inject(function($injector) {
      _$rootScope = $injector.get('$rootScope');
      _expName = $injector.get('expName');

    });

  });

  it("It should test updateName method", function() {

    var name = "ChaiBio";
    spyOn(_$rootScope, "$broadcast");

    _expName.updateName(name);

    expect(_expName.name).toEqual(name);
    expect(_$rootScope.$broadcast).toHaveBeenCalled();
  });
});
