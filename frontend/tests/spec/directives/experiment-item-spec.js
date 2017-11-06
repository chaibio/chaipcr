describe("Test RUN/VIEW item directive, which shows up in left menu", function() {

  beforeEach(function () {
    module('ChaiBioTech', function ($provide) {
      $provide.value('IsTouchScreen', function () {})
    });
  });

  var scope, controllerService, httpMock, compile, templateCache, state, rootScope, Experiment;

  beforeEach(inject(function ($rootScope, $httpBackend, $compile, $templateCache, $state, Experiment) {
    scope = $rootScope.$new();
    rootScope = $rootScope;
    httpMock = $httpBackend;
    compile = $compile;
    templateCache = $templateCache;
    Exp = Experiment;
    state = $state;
    state.go("edit-protocol");
    httpMock.whenGET("http://localhost:8000/status").respond("NOTHING");
    httpMock.whenGET("http://localhost:8000/network/wlan").respond("NOTHING");
    httpMock.expectPOST("http://localhost:8000/control/start").respond({});

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
    expect(angular.element(compiled).html()).not.toContain("Lid is open");
  });

  it("if lid is open show additional message 'Lid is open'", function () {

    var elem = angular.element('<experiment-item state-val="RUNNING" lid-open="false"></experiment-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    compiledScope.lidOpen = true;
    compiledScope.state = "NOT_STARTED";
    scope.$digest();
    expect(angular.element(compiled).html()).toContain("Lid is open");
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

  it("Checks if the click on .exp-message calls manageAction() method and redirects", function() {

    var elem = angular.element('<experiment-item state-val="RUNNING" lid-open="false"></experiment-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();

    var compiledScope = compiled.isolateScope();
    spyOn(compiledScope, "manageAction").and.callThrough();
    spyOn(state, 'go');
    compiled.find(".exp-message").click();
    scope.$digest();
    expect(compiledScope.manageAction).toHaveBeenCalled();
    expect(state.go).toHaveBeenCalled();
  });


  it("Checks if the click on CONFIRM calls startExp() method", function() {

    var elem = angular.element('<experiment-item state-val="NOT_STARTED" lid-open="false"></experiment-item>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();

    spyOn(compiledScope, "manageAction").and.callThrough();
    spyOn(compiledScope, "startExp").and.callThrough();
    spyOn(Exp, 'startExperiment').and.callThrough();
    spyOn(rootScope, '$broadcast').and.callThrough();
    spyOn(Exp, "getMaxExperimentCycle").and.callThrough();
    spyOn(state, 'go');

    compiled.find(".exp-message").click();
    scope.$digest();

    expect(compiledScope.runReady).toEqual(true);
    expect(compiledScope.manageAction).toHaveBeenCalled();

    compiled.find(".success").click();
    //httpMock.flush();
    expect(compiledScope.startExp).toHaveBeenCalled();
    expect(Exp.startExperiment).toHaveBeenCalled();
    //state.go('edit-protocol');
    //expect(Exp.getMaxExperimentCycle).toHaveBeenCalled();
    expect(rootScope.$broadcast).toHaveBeenCalled();
    //expect(state.go).toHaveBeenCalled();
  });
});
