describe("Test temperature directive", function() {

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

            var elem = angular.element('<temperature caption="Temperature" help-text="[4-100     ºC]" unit="ºC" reading="100" action="WOWaction(edit)"></temperature>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.delta).toEqual(true);
        expect(compiledScope.edit).toEqual(false);
        expect(compiledScope.temp).toEqual(true);
        expect(compiledScope.pause).toEqual(true);
    });

    it("It should watch reading", function() {

        compiledScope.reading = 12.456;
        compiledScope.$digest();

        expect(compiledScope.shown).toEqual(compiledScope.reading.toFixed(1));

    });

    it("It should $watch edit when edit is true", function() {
        spyOn($.fn, "animate").and.returnValue(true);
        compiledScope.edit = true;
        compiledScope.$digest();   
        expect($.fn.animate).toHaveBeenCalled();

    });

    it("It should test editAndFocus method", function() {

        compiledScope.edit = false;
        compiledScope.$digest();
        compiledScope.editAndFocus();
        expect(compiledScope.edit).toEqual(true);
    });

    it("It should test save method", function() {

        compiledScope.shown = 15;
        compiledScope.$digest();
        compiledScope.editAndFocus();

        compiledScope.shown = 10;
        compiledScope.$digest();

        compiledScope.save();

        expect(compiledScope.reading).toEqual('10.0');
    });

    it("It should test save method when shown is not a number", function() {

        compiledScope.shown = 15;
        compiledScope.$digest();
        compiledScope.editAndFocus();

        compiledScope.shown = "kwel";
        compiledScope.$digest();

        compiledScope.save();

        expect(compiledScope.shown).toEqual('100.0');
    });
});