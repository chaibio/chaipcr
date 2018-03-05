describe("Testing EditExperimentPropertiesCtrl", function() {

    var _$scope, _focus, _Experiment, _$stateParams, _expName, _Protocol, _Status, _$timeout, $rootScope;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            
            _$rootScope = $injector.get('$rootScope');        
            _$scope = _$rootScope.$new();
            _$controller = $injector.get('$controller');
            _Experiment = $injector.get('Experiment');
            _$state = $injector.get('$state');
            _$stateParams = $injector.get('$stateParams');
            _expName = $injector.get('expName');
            _Status = $injector.get('Status');
            _$timeout = $injector.get('$timeout');
            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.expectPUT("http://localhost:8000/network/eth0").respond({
                status: {
                    
                }
            });

            EditExperimentPropertiesCtrl = _$controller('EditExperimentPropertiesCtrl', {
                $scope: _$scope,
            });
        });        
    });

    it("It should test init value", function() {

        _Experiment.get = function(obj,callback) {
            var data = {
                experiment: {
                    id: 100
                }
            };

            if(callback) {
                callback(data);
            }

            return {
                then: function(callback) {
                    var data = {
                        experiment: {
                            id: 100,
                            started_at: "10-12-2018"
                        }
                    };
                    callback(data);
                }
            };
        };

        _Experiment.setCurrentExperiment = function(data) {

        };

        spyOn(_Experiment, "get").and.callThrough();
        spyOn(_Experiment, "setCurrentExperiment").and.callThrough();

        EditExperimentPropertiesCtrl = _$controller('EditExperimentPropertiesCtrl', {
            $scope: _$scope,
        });

        expect(_Experiment.get).toHaveBeenCalled();
        expect(_Experiment.setCurrentExperiment).toHaveBeenCalled();
        expect(_$scope.editExpNameMode).toEqual(false);

    });

    it("It should test getData method when started_at && completed_at are null", function() {

       /* _Experiment.get = function() {

            return {
                then: function(callback) {
                    var data = {
                        experiment: {
                            started_at: null,
                            completed_at: null
                        }
                    };
                    callback();
                }
            };
        };

        _$scope.getData();

        expect(_$scope.status).toEqual('NOT_STARTED');
        expect(_$scope.runStatus).toEqual('Not run yet.'); 
        */
       // This method is not attached to $scope.
    });

    it("It should test removeMessages", function() {

        _$scope.removeMessages();

        expect(_$scope.successLid).toEqual(null);
        expect(_$scope.successName).toEqual(null);
        expect(_$scope.errors).toEqual(null);
    });
});