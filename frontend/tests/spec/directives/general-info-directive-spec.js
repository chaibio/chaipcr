describe("Testing general directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus;

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
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");

            var stage = {
                auto_delta: true
            };

            var step = {
                delta_duration_s: 10
            };
            var elem = angular.element('<general></general>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.scope();
            
        });
    }); 

    it("It should test initial values", function() {
        expect(compiledScope.stageNoCycleShow).toEqual(false);
        expect(compiledScope.popUp).toEqual(false);
        expect(compiledScope.showCycling).toEqual(false);
        expect(compiledScope.warningMessage).toEqual("You have entered a wrong value. Please make sure you enter digits in the format HH:MM:SS.");
        expect(compiledScope.stepNameShow).toEqual(false);
    });

    it("It should test dataLoaded event", function() {

        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();

        compiledScope.$emit("dataLoaded");

        expect(compiledScope.delta_state).toEqual("ON");
    });

    it("It should test dataLoaded event and popUp change", function() {

        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();
        compiledScope.$emit("dataLoaded");
        
        compiledScope.popUp = true;
        compiledScope.$digest();
        expect(_popupStatus.popupStatusGatherData).toEqual(compiledScope.popUp);

    });

    it("It should test dataLoaded event and step.id change", function() {

        spyOn(_$rootScope, "$broadcast").and.returnValue(true);
        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();
        compiledScope.$emit("dataLoaded");

        compiledScope.fabricStep = {};
        compiledScope.step = {
            id: 100
        };
        compiledScope.$digest();

        expect(_$rootScope.$broadcast).toHaveBeenCalled();
    });
});