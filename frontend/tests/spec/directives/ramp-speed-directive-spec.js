describe("It should test rampSpeed dirctive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus, _TimeService;

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

            var elem = angular.element('<ramp-speed caption="Ramp Speed" help-text="[0-5&nbsp;&nbsp;ºC/s]" unit="ºC/s" reading="step.ramp.rate"></ramp-speed>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.edit).toEqual(false);
        expect(compiledScope.delta).toEqual(true);
        expect(compiledScope.ramp).toEqual(true);
        expect(compiledScope.pause).toEqual(true);
    });

    it("It should test $watch reading", function() {

        spyOn(compiledScope, "configureData").and.returnValue(true);
        compiledScope.reading = "cool";
        compiledScope.$digest();
        expect(compiledScope.configureData).toHaveBeenCalled();
    });

    it("It should test $watch edit", function() {

        spyOn(angular, "element").and.callThrough();
        compiledScope.edit = true;
        compiledScope.$digest();

    });

    it("It should test $watch edit", function() {

        spyOn(angular, "element").and.callThrough();
        compiledScope.edit = false;
        compiledScope.$digest();

    });
});