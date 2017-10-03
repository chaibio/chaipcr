describe("Testing alerts", function() {

  var _alerts, _$uibModal;

  beforeEach(function() {

    module('ChaiBioTech', function($provide) {
      mockCommonServices($provide);
    });

    inject(function($injector) {
      _alerts = $injector.get('alerts');
      _$uibModal = $injector.get('$uibModal');
    });
  });

  it("It should test showMessage method", function() {

    $scope = {

    };

    var templateUrl = null;

    _alerts.showMessage(_alerts.noOfCyclesWarning, $scope, templateUrl);

    expect($scope.warningMessage).toEqual(_alerts.noOfCyclesWarning);
    expect($scope.modal).toEqual(jasmine.any(Object));
    expect($scope.modal.close).toEqual(jasmine.any(Function));
  });

});
