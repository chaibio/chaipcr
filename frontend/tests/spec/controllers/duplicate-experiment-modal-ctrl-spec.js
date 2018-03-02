describe("Testing DuplicateExperimentModalCtrl", function() {

    var _$scope, _Experiment, _$state, _$rootScope, DuplicateExperimentModalCtrl;

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
            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.expectPUT("http://localhost:8000/network/eth0").respond({
                status: {
                    
                }
            });

            _DuplicateExperimentModalCtrl = _$controller('DuplicateExperimentModalCtrl', {
                $scope: _$scope,
            });
        });
        
       
    });

    it("It should test focus method", function() {

        _$scope.newExperimentName = "New Experiment";

        _$scope.$digest();

        _$scope.focus();

        expect(_$scope.focused).toEqual(true);
        expect(_$scope.submitted).toEqual(false);
        expect(_$scope.error).toEqual(null);
        expect(_$scope.newExperimentName).toEqual('');
    });

    it("It should test focus method when newExperimentName !== 'New Experiment'", function() {

        _$scope.newExperimentName = "New";

        _$scope.$digest();

        _$scope.focus();

        expect(_$scope.focused).toEqual(true);
        expect(_$scope.submitted).toEqual(false);
        expect(_$scope.error).toEqual(null);
        expect(_$scope.newExperimentName).toEqual('New');

    });

    it("It should test unfocus method", function() {

        _$scope.newExperimentName = null;

        _$scope.$digest();

        _$scope.unfocus();

        expect(_$scope.focused).toEqual(false);
        expect(_$scope.newExperimentName).toEqual("New Experiment");
    });

    it("It should test unfocus method, when newExperimentName !== null", function() {

        _$scope.newExperimentName = "New";

        _$scope.$digest();

        _$scope.unfocus();

        expect(_$scope.focused).toEqual(false);

        expect(_$scope.newExperimentName).toEqual("New");
    });

    it("It should test submit method and success method", function() {

        _$scope.form = {
            $valid: true
        };

        _$scope.newExperimentName = "ChaiBio";
        
        _$scope.$close = function() {
        
        };

        _$state.go = function() {

        };
        _Experiment.duplicate = function() {

            return {
                success: function(callback) {
                    var resp = {
                        experiment: {
                            id: 100
                        }
                    };
                    callback(resp);
                },
                error: function() {

                }
            };
        };
        
        spyOn(_$state, "go").and.callThrough();
        spyOn(_Experiment, "duplicate").and.callThrough();

        _$scope.submit();

        expect(_$state.go).toHaveBeenCalled();
        expect(_$scope.submitted).toEqual(true);
        expect(_$scope.loading).toEqual(true);
    });

    it("It should test submit method and error method", function() {

        _$scope.form = {
            $valid: true
        };

        _$scope.newExperimentName = "ChaiBio";
        
        _$scope.$close = function() {
        
        };

        _$state.go = function() {

        };
        _Experiment.duplicate = function() {

            return {
                success: function() {
                    /*var resp = {
                        experiment: {
                            id: 100
                        }
                    };
                    callback(resp); */
                },
                error: function(callback) {
                    callback();
                }
            };
        };
        
        spyOn(_$state, "go").and.callThrough();
        spyOn(_Experiment, "duplicate").and.callThrough();

        _$scope.submit();

        expect(_$state.go).not.toHaveBeenCalled();
        expect(_$scope.submitted).toEqual(true);
        expect(_$scope.error).toEqual("Unable to copy experiment!");
        expect(_$scope.loading).toEqual(false);
    });

    it("It should test submit method when form.$valid === false", function() {

        _$scope.form = {
            $valid: false
        };

        _$scope.newExperimentName = "ChaiBio";
        
        _$scope.$close = function() {
        
        };

        _$state.go = function() {

        };
        _Experiment.duplicate = function() {

            return {
                success: function() {
                    /*var resp = {
                        experiment: {
                            id: 100
                        }
                    };
                    callback(resp); */
                },
                error: function(callback) {
                    callback();
                }
            };
        };
        
        spyOn(_$state, "go").and.callThrough();
        spyOn(_Experiment, "duplicate").and.callThrough();

        _$scope.submit();

        expect(_$state.go).not.toHaveBeenCalled();
        expect(_Experiment.duplicate).not.toHaveBeenCalled();
    });


});