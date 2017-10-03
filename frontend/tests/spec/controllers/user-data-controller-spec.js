describe("Testing userDataController", function() {

  beforeEach(module('ChaiBioTech', function ($provide) {
    $provide.value('IsTouchScreen', function () {}) 
  }));

  var $controller;

  beforeEach(inject(function(_$controller_) {
      $controller = _$controller_;
  })
);

  it("ChaiBioTech should have userDataController", function() {
    expect(ChaiBioTech.userDataController).not.toBe(null);
  });

  it("Check reset pass", function() {
    var $scope = {};
    var controller = $controller('userDataController', {$scope: $scope});
    $scope.resetPass();
    expect($scope.resetPassStatus).toBe(true);
  });
});
