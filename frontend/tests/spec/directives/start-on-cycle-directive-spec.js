describe("Testing startOnCycle",function() {

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

            var elem = angular.element('<start-on-cycle caption="Start On Cycle" delta="true" reading="10"></start-on-cycle>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.edit).toEqual(false);
        expect(compiledScope.showCapsule).toEqual(false);
    });

    it("It should watch change in reading", function() {

        compiledScope.reading = 15;
        compiledScope.$digest();

        expect(compiledScope.shown).toEqual(15);
    });

    it("It should test editAndFocus method", function() {

        compiledScope.delta = true;
        compiledScope.$digest();
        compiledScope.editAndFocus();
    });

    it("It should test save method when shown is <= 0", function() {

        spyOn(_alerts, "showMessage").and.returnValue(true);
        compiledScope.shown = 0;
        compiledScope.$digest();
        compiledScope.save();

        expect(compiledScope.shown).toEqual(1);
        expect(_alerts.showMessage).toHaveBeenCalled();
    });

    it("It should test save method when Number(scope.shown) <= Number(scope.$parent.stage.num_cycles)", function() {

        compiledScope.shown = 5;
        compiledScope.$digest();
        compiledScope.editAndFocus();

        compiledScope.$parent = {
            stage: {
                num_cycles: 20
            }
        };

        compiledScope.shown = 15;
        compiledScope.delta = true;

        compiledScope.$digest();
        compiledScope.save();

        expect(compiledScope.reading).toEqual(compiledScope.shown);
    });

    it("It should test save method new value is greater than number of cycles", function() {

        compiledScope.$parent = {
            stage: {
                num_cycles: 20
            }
        };

        compiledScope.shown = 45;
        compiledScope.delta = true;
        spyOn(_alerts, "showMessage").and.returnValue(true);
        compiledScope.$digest();
        compiledScope.save();

        expect(_alerts.showMessage).toHaveBeenCalled();
    });
    
    it("It should test save method when shown is not a number", function() {

        compiledScope.shown = 18;
        compiledScope.$digest();
        compiledScope.editAndFocus();

        compiledScope.shown = "stuv";
        compiledScope.$digest();
        compiledScope.save();
        expect(compiledScope.shown).toEqual(18);
    });
});