describe("Testing menu overlay [Shows up when we enable side menu]", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    $provide.value('IsTouchScreen', function () {});
  }));

  var compile, rootScope, scope, httpMock;

  beforeEach(inject(function($compile, $rootScope, $httpBackend, $stateParams) {
      compile = $compile;
      scope = $rootScope.$new();
      rootScope = $rootScope;
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
      httpMock.whenGET("/experiments/" + $stateParams.id).respond(data);
    })
  );

  it("checks the initial data of the menu-overlay", function() {
    var elem = angular.element("<menu-overlay>something to transclude</menu-overlay>");
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    expect(compiledScope.sideMenuOpen).toEqual(false);
  });

  it("checks 'sidemenu:toggle' event", function() {
    var elem = angular.element("<menu-overlay>something to transclude</menu-overlay>");
    var compiled = compile(elem)(scope);
    scope.$digest();
    var compiledScope = compiled.isolateScope();
    rootScope.$broadcast('sidemenu:toggle');
    expect(compiledScope.sideMenuOpen).toBeTruthy();
  });

  it("checks Transclusion", function() {
    var elem = angular.element("<menu-overlay>something to transclude</menu-overlay>");
    var compiled = compile(elem)(scope);
    scope.$digest();
    var pageContainerHTML = compiled.find(".page-container").html();
    expect(pageContainerHTML).toContain("something to transclude");
  });
});
