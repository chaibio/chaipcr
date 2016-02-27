describe("Test protocol item directive, which shows in left menu", function() {

  beforeEach(module('ChaiBioTech'));
  //beforeEach(module('foo'));
  //var $compile, $rootScope,
  //validHTML = '<menu-overlay>Dummy data</menu-overlay>';

  beforeEach(inject(function($compile, $rootScope, $templateCache) {
      //el = angular.element('<protocol-item state="{{status}}"></protocol-item>');
      //var template = $templateCache.get('app/views/directives/protocol-item.html');
      scope = $rootScope.$new();

      console.log(scope);
      elem = angular.element('<protocol-item ></protocol-item>');
      var compiled = $compile(elem)(scope);
      scope.message = "cool";
      scope.$digest();
      console.log(compiled);
    })
  );

  it("checks the initial data of the menu-overlay", function() {
    //var elem = angular.element(validHTML);
    //var elem = $compile(elem)($rootScope);
    //$rootScope.$apply();
    //var elemScope = elem.isolateScope();
    //console.log(elemScope);
  });
});
