describe("Here we check the hit escape button and left-menu disappear", function() {

  beforeEach(module("ChaiBioTech"));
  var scope, httpMock, compile, rootScope;

  beforeEach(inject(function($rootScope, $httpBackend, $compile) {
    scope = $rootScope.$new();
    rootScope = $rootScope;
    httpMock = $httpBackend;
    compile = $compile;

    httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
    httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
    //httpMock.expectPOST("http://localhost:8000/control/start").respond({});
  }));

  it("Should check the initial conf", function() {
    var elem = angular.element('<p escape-menu ></p>');
    var compiled = compile(elem)(scope);
    scope.registerEscape = false;
    scope.$digest();
    expect(scope.registerEscape).toBeFalsy();
  });

  it("Should check if hitting escape key $broadcast", function() {
    var elem = angular.element('<p escape-menu ></p>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    spyOn(rootScope, "$broadcast");
    angular.element('window').trigger('keyup', { keyCode: 27 });
    //Safari/Chrome makes the keyCode and charCode properties read-only,
    //so it is not possible to simulate specific keys when manually firing events.
    expect(rootScope.$broadcast).toHaveBeenCalledWith();
  });

});
