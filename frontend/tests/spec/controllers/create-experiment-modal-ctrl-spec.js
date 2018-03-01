describe("Testing CreateExperimentModalCtrl", function() {

    var _$scope, _Experiment, _CreateExperimentModalCtrl, _$rootScope;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
    
            _$rootScope = $injector.get('$rootScope');        
            _$scope = _$rootScope.$new();
            _$controller = $injector.get('$controller');
            _Experiment = $injector.get('Experiment');
            httpMock = $injector.get('$httpBackend');

            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.expectPUT("http://localhost:8000/network/eth0").respond({
                status: {
                    
                }
            });
            
            _CreateExperimentModalCtrl = _$controller('CreateExperimentModalCtrl', {
                $scope: _$scope,
            });
            
        });
    });

    it("It should test initial values of scope", function() {

        expect(_$scope.newExperimentName).toEqual('New Experiment');
        expect(_$scope.focused).toEqual(false);
        expect(_$scope.loading).toEqual(false);
    });

    it("It should test focus method", function() {

        _$scope.newExperimentName = "New Experiment";
        _$scope.$digest();

        _$scope.focus();

        expect(_$scope.focused).toEqual(true);
        expect(_$scope.submitted).toEqual(false);
        expect(_$scope.newExperimentName).toEqual('');

    });

    it("It should test unfocus method", function() {

        _$scope.newExperimentName = null;
        _$scope.$digest();

        _$scope.unfocus();

        expect(_$scope.newExperimentName).toEqual('New Experiment');
    });

    it("It should test submit method with success callback", function() {

        _Experiment = function() {
            return {
                $save: function() {
                    return {
                        then: function(callback) {                            
                            //console.log(callback);
                            callback(data);
                        }
                    };
                }
            };
        };

        _$scope.form = {
            $valid: true
        };

        _$scope.newExperimentName = "new";

        _$scope.$close = function() {

        };

        _$scope.$digest();

        spyOn(_$scope, "$close");
        _$scope.submit("delta");

        expect(_$scope.submitted).toEqual(true);
        expect(_$scope.loading).toEqual(true);
        //expect(_$scope.$close).toHaveBeenCalled();
    });

   /* it("It should test submit method with error callback", function() {

        _Experiment = function() {
            return {
                $save: function() {
                    return {
                        then: function(callback, errorCallback) {
                            data = {
                                experiment: {

                                }
                            };
                            errorCallback({});
                        }
                    };
                }
            };
        };

        _$scope.form = {
            $valid: true
        };

        _$scope.newExperimentName = "new";

        _$scope.$close = function() {

        };

        _$scope.$digest();

        spyOn(_$scope, "$close");
        _$scope.submit("delta");

        expect(_$scope.error).toEqual(true);
        expect(_$scope.loading).toEqual(false);
        //expect(_$scope.$close).toHaveBeenCalled();
    });
    */
});