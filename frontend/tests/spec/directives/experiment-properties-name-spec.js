describe("Specs for edit Exp name in the left menu", function() {

  beforeEach(module("ChaiBioTech", function ($provide) {
    $provide.value('IsTouchScreen', function() {});
  }));

  var scope, compile, httpMock, elem, compiled;

  beforeEach(inject(function($rootScope, $compile, $httpBackend) {
    scope = $rootScope.$new();
    compile = $compile;
    httpMock = $httpBackend;
    httpMock.whenGET("http://localhost:8000/status").respond("NOTHING");
    httpMock.whenGET("http://localhost:8000/network/wlan").respond("NOTHING");
    httpMock.whenGET("/experiments/").respond("NOTHING");
    httpMock.whenGET("/experiments/undefined").respond("NOTHING");
    elem = angular.element('<edit-exp-name status="NOT_STARTED"></edit-exp-name>');
    compiled = compile(elem)(scope);
  }));

  it("Should check initial values of the dirctive", function() {

    scope.$digest();
    var compiledScope = compiled.isolateScope();
    expect(compiledScope.editExpNameMode).toBeFalsy();
  });


  it("Should check if the click on the name make editMode active and blur should call saveExperiment", function() {

    scope.$digest();
    var compiledScope = compiled.isolateScope();
    spyOn(compiledScope, "focusExpName");
    compiled.find(".exp-name").click();
    scope.$digest();
    expect(compiledScope.focusExpName).toHaveBeenCalled();

    spyOn(compiledScope, "saveExperiment");
    compiled.find(":text").blur();
    scope.$digest();
    expect(compiledScope.saveExperiment).toHaveBeenCalled();

  });

});
