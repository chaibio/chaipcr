describe("Checking the behaviour of menu overlay controller", function() {

  beforeEach(module('ChaiBioTech', function($provide) {
    $provide.value('IsTouchScreen', function () {});
  }));

  var $controller, $rootScope, httpMock, stateParams, $scope, ExperimentMenuOverlayCtrl, deferred, data;

  beforeEach(inject(function(_$controller_, _$rootScope_, $httpBackend, $stateParams, $q) {
      $controller = _$controller_;
      $rootScope = _$rootScope_;
      httpMock = $httpBackend;
      stateParams = $stateParams;
      stateParams.id = 1;
      httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
      httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
      data = {
        experiment: {
          "started_at": true,
          "completed_at": true,
          protocol: {
            stages: {}
          }
        }
      };

      //httpMock.expectGET("/experiments/" + stateParams.id).respond(data);
      deferred = $q.defer();
      Experiment = {
        get: function(id) {
          return {
            then: function(fn) {
              fn(data);
            }
          };
        }
      };

      spyOn(Experiment, "get").and.callThrough();

      $scope = $rootScope.$new();
      ExperimentMenuOverlayCtrl = $controller('ExperimentMenuOverlayCtrl', {$scope: $scope, Experiment: Experiment});
      //httpMock.flush();
  })
);

  it("ChaiBioTech should have ExperimentMenuOverlayCtrl", function() {
    expect(ChaiBioTech.ExperimentMenuOverlayCtrl).not.toEqual(null);
  });

  it("Checks the functionality of show hide, Setting showProperties = true should set HIDE", function() {

    $scope.showProperties = true;
    $scope.$digest();
    expect($scope.showHide).toEqual("HIDE");
  });

  it("Checks the functionality of show hide, Setting showProperties = false should set SHOW", function() {

    $scope.showProperties = false;
    $scope.$digest();
    expect($scope.showHide).toEqual("SHOW");
  });

  it("Checks the functionality of getExperiment() Method", function() {
    $scope.getExperiment();
    $scope.$digest();
    expect($scope.status).toEqual('COMPLETED');
    expect($scope.runStatus).toEqual('Run on:');
    expect(Experiment.get).toHaveBeenCalled();

  });

});
