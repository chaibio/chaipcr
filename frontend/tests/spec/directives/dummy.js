describe("see if its working", function() {

  beforeEach(module("ChaiBioTech", function(ch) {
    console.log(ch, "JossieDan");
  }));
  //beforeEach(module("canvasApp"));

  var scope, httpMock, compile, rootScope;


  //beforeEach(inject(function() {
    //scope = $rootScope.$new();
    //rootScope = $rootScope;
    //httpMock = $httpBackend;
    //compile = $compile;
    //httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
    //httpMock.expectPOST("http://localhost:8000/control/start").respond({});
  //}));

  it("Should be alright", function() {
    x = 1;
    expect(x).toEqual(1);
  });
});
