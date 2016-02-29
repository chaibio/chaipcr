describe("Checking the behaviour of menu overlay controller", function() {

  beforeEach(module('ChaiBioTech'));

  var $controller, $rootScope, httpMock;

  beforeEach(inject(function(_$controller_, _$rootScope_, $httpBackend) {
      $controller = _$controller_;
      $rootScope = _$rootScope_;
      httpMock = $httpBackend;
      httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
  })
);

  it("ChaiBioTech should have ExperimentMenuOverlayCtrl", function() {
    expect(ChaiBioTech.ExperimentMenuOverlayCtrl).not.toBe(null);
  });

  it("Checks the functionality of show hide", function() {

    var $scope = $rootScope.$new();
    var controlScope = $controller('ExperimentMenuOverlayCtrl', {$scope: $scope});
    //$scope.showProperties = true;
    //$scope.$digest();

    controlScope.showProperties = true;
    console.log($scope.showHide);
    $scope.$digest();
    expect($scope.showHide).toBeTruthy();
    //expect($scope.sh)
  });

  /*it("Check reset pass", function() {
    var $scope = {};
    var controller = $controller('userDataController', {$scope: $scope});
    //$scope.resetPass();
    //expect($scope.resetPassStatus).toBe(true);
  });*/
});
