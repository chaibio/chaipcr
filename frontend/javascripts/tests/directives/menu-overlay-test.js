describe("Testing menu overlay [Shows up when we enable side menu]", function() {

  beforeEach(module('ChaiBioTech'));

  var compile, rootScope, scope, httpMock;
  //validHTML = '<menu-overlay>Dummy data</menu-overlay>';

  beforeEach(inject(function($compile, $rootScope, $httpBackend) {
      compile = $compile;
      scope = $rootScope.$new();
      httpMock = $httpBackend;
      httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
    })
  );

  it("checks the initial data of the menu-overlay", function() {

    /*var elem = angular.element('<div><menu-overlay>Data to be transcluded</menu-overlay></div>');
    var compiled = compile(elem)(scope);
    scope.$digest();
    //var compiledScope = compiled.isolateScope();
    console.log("okay");
    //expect(compiledScope.sideMenuOpen).to.be.falsy();*/
  });

});
