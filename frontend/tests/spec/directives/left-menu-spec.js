describe("Specs for left menu directive", function() {

  beforeEach(module("ChaiBioTech", function ($provide) {
    $provide.value('IsTouchScreen', function () {}); 
  }));
  
  var scope, compile, httpMock, paramId = 10;

  beforeEach(inject(function($rootScope, $compile,$httpBackend, $stateParams) {
    scope = $rootScope.$new();
    compile = $compile;
    httpMock = $httpBackend;
    httpMock.whenGET("http://localhost:8000/status").respond("NOTHING");
    httpMock.whenGET("http://localhost:8000/network/wlan").respond("NOTHING");
    $stateParams.id = 10;

    var data = {
      experiment: {
        "started_at": true,
        "completed_at": true,
        protocol: {
          stages: {}
        }
      }
    };
    httpMock.whenGET("/experiments/" + paramId).respond(data);
  }));

  it("Should check the functionality of left-menu init, It should show SHOW", function() {
    var elem = angular.element("<left-menu></left-menu>");
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    expect(scope.showHide).toEqual("SHOW");
  });

  it("Should check the click on Experiment Properties item in the left menu", function() {
    var elem = angular.element("<left-menu></left-menu>");
    var compiled = compile(elem)(scope);
    scope.$digest();
    compiled.find(".sidemenu-show-text").click();
    expect(scope.showHide).toEqual("HIDE");
  });

  it("Should check the click on delete experement", function() {
    var elem = angular.element("<left-menu></left-menu>");
    var compiled = compile(elem)(scope);
    scope.$digest();
    spyOn(scope, 'deleteExperiment');
    compiled.find(".second-button").click();
    expect(scope.deleteExperiment).toHaveBeenCalledWith(paramId);
  });
});
