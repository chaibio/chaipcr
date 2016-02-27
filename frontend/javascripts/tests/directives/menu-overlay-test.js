describe("Testing menu overlay [Shows up when we enable side menu]", function() {

  beforeEach(module('ChaiBioTech'));

  var $compile, $rootScope,
  validHTML = '<menu-overlay>Dummy data</menu-overlay>';

  beforeEach(inject(function(_$compile_, _$rootScope_) {
      $compile = _$compile_;
      $rootScope = _$rootScope_.$new();
    })
  );

  it("checks the initial data of the menu-overlay", function() {
    var elem = angular.element(validHTML);
    var elem = $compile(elem)($rootScope);
    //$rootScope.$apply();
    var elemScope = elem.isolateScope();
    console.log(elemScope);
  });

});
