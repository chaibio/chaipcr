describe("Test protocol item directive, which shows in left menu", function() {

  beforeEach(module('ChaiBioTech'));

  var scope, controllerService, httpMock, compile, templateCache;

  beforeEach(inject(function ($rootScope, $httpBackend, $compile, $templateCache) {
    scope = $rootScope.$new();
    httpMock = $httpBackend;
    compile = $compile;
    templateCache = $templateCache;
    httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
    httpMock.whenGET("http://localhost:8000/network/wlan").respond("NOTHING");
  }));

  it("Passing NOT_STARTED should set the message to EDIT PROTOCOL ", function () {

    var elem = angular.element('<protocol-item state="NOT_STARTED"></protocol-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    expect(compiledScope.message).toBe("EDIT PROTOCOL");
  });

  it("Passing anything other that NOT_STARTED should set the message to VIEW PROTOCOL", function(){

    var elem = angular.element('<protocol-item state="test val"></protocol-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    expect(compiledScope.message).toBe("VIEW PROTOCOL");
  });

  it("Passing NOT_STARTED should render html with EDIT PROTOCOL", function() {

    var elem = angular.element('<protocol-item state="NOT_STARTED"></protocol-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    expect(compiled.html()).toContain("EDIT PROTOCOL");
  });

  it("Passing anything other than NOT_STARTED should render html with EDIT PROTOCOL", function() {

    var elem = angular.element('<protocol-item state="test input"></protocol-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    expect(compiled.html()).toContain("VIEW PROTOCOL");
  });

});
