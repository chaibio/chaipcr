describe("Test RUN/VIEW item directive, which shows up in left menu", function() {

  beforeEach(module('ChaiBioTech'));

  var scope, controllerService, httpMock, compile, templateCache;

  beforeEach(inject(function ($rootScope, $httpBackend, $compile, $templateCache) {
    scope = $rootScope.$new();
    httpMock = $httpBackend;
    compile = $compile;
    templateCache = $templateCache;
    httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
  }));

  it("passing NOT_STARTED should show RUN EXPERIMENT", function () {

    var elem = angular.element('<experiment-item state-val="NOT_STARTED" lid-open="false"></experiment-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    expect(compiledScope.message).toEqual("RUN EXPERIMENT");
  });

  it("passing COMPLETED should show VIEW RESULT", function () {

    var elem = angular.element('<experiment-item state-val="COMPLETED" lid-open="false"></experiment-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    expect(compiledScope.message).toEqual("VIEW RESULT");
  });

  it("passing RUNNING should show EXPERIMENT STATUS", function () {

    var elem = angular.element('<experiment-item state-val="RUNNING" lid-open="false"></experiment-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    expect(compiledScope.message).toBe("EXPERIMENT STATUS");
    expect(compiledScope.runReady).toBeFalsy();
    expect(angular.element(compiled).html()).not.toContain("Hardware lid is open");
  });

  it("if lid is open show additional message 'Hardware lid is open'", function () {

    var elem = angular.element('<experiment-item state-val="RUNNING" lid-open="false"></experiment-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    compiledScope.lidOpen = true;
    compiledScope.state = "NOT_STARTED";
    scope.$digest();
    expect(angular.element(compiled).html()).toContain("Hardware lid is open");
  });

  it("Checks if the click on .exp-message calls manageAction() method", function() {

    var elem = angular.element('<experiment-item state-val="NOT_STARTED" lid-open="false"></experiment-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();

    var compiledScope = compiled.isolateScope();
    spyOn(compiledScope, "manageAction").and.callThrough();
    compiled.find(".exp-message").click();
    scope.$digest();
    expect(compiledScope.runReady).toEqual(true);
    expect(compiledScope.manageAction).toHaveBeenCalled();

  });
});
