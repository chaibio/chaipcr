describe("Testing stageTypePopup", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus, _TimeService, _addStageService;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            _$compile = $injector.get('$compile');
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _canvas = $injector.get('canvas');
            _$timeout = $injector.get('$timeout');
            _HomePageDelete = $injector.get('HomePageDelete');
            _$uibModal = $injector.get('$uibModal');
            _alerts = $injector.get('alerts');
            _popupStatus = $injector.get('popupStatus');
            httpMock = $injector.get('$httpBackend');
            _TimeService = $injector.get('TimeService');
            _addStageService = $injector.get('addStageService');

            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");

            var stage = {
                auto_delta: true
            };

            var step = {
                delta_duration_s: 10,
                hold_time: 20,
                pause: true
            };

            var elem = angular.element('<stage-type-popup ng-show="true"></stage-type-popup>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.scope();
            
        });
    });

    it("It should test addStage method", function() {

        spyOn(_ExperimentLoader, "addStage").and.returnValue({
            then: function(callback) {
                callback({});
            }
        });

        spyOn(_addStageService, "addNewStage").and.returnValue(true);

        compiledScope.fabricStep = {
            parentStage: {

            }
        };
        compiledScope.addStage();

        expect(_ExperimentLoader.addStage).toHaveBeenCalled();
        expect(_addStageService.addNewStage).toHaveBeenCalled();
    });

    it("It should test addStage method when infiniteHold is false", function() {

        spyOn(_ExperimentLoader, "addStage").and.returnValue({
            then: function(callback) {
                callback({});
            }
        });

        spyOn(_addStageService, "addNewStage").and.returnValue(true);

        compiledScope.fabricStep = {
            parentStage: {
                
            }
        };
        compiledScope.infiniteHold = true;
        compiledScope.$digest();
        compiledScope.addStage();

        expect(_ExperimentLoader.addStage).not.toHaveBeenCalled();
        expect(_addStageService.addNewStage).not.toHaveBeenCalled();
    });

});