describe("testing time directive", function() {

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

            var elem = angular.element('<time caption="Δ Time" delta="true" reading="100"><capsule func="changeDeltaTime" delta="{{stage.auto_delta}}" data="step.delta_duration_s"></capsule></time>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.showCapsule).toEqual(true);

    });

    it("It should test change in reading", function() {

        spyOn(_TimeService, "newTimeFormatting").and.returnValue(10);
        compiledScope.reading = 20;
        compiledScope.$digest();
        expect(_TimeService.newTimeFormatting).toHaveBeenCalled();
    });

    it("It should test editAndFocus method", function() {

        spyOn(_TimeService, "convertToSeconds").and.returnValue(true);
        compiledScope.delta = true;
        compiledScope.$digest();
        compiledScope.editAndFocus();
        expect(_TimeService.convertToSeconds).toHaveBeenCalled();
    });

    it("It should test save method", function() {
        
        _TimeService.convertToSeconds = function(val) {
            return val;
        };

        spyOn(_TimeService, "convertToSeconds").and.callThrough();

        compiledScope.shown = 30;
        compiledScope.$digest();
        compiledScope.editAndFocus();
        compiledScope.shown = 40;
        compiledScope.$digest();
        //spyOn(_TimeService, "convertToSeconds").and.returnValue(35);
        compiledScope.save();
        expect(compiledScope.reading).toEqual(40);
        expect(_TimeService.convertToSeconds).toHaveBeenCalled();
        
    });

    it("It should test save method when first condition is not met", function() {

        spyOn(_alerts, "showMessage").and.returnValue(true);
        _TimeService.convertToSeconds = function(val) {
            return undefined;
        };

        spyOn(_TimeService, "newTimeFormatting").and.returnValue(100);
        spyOn(_TimeService, "convertToSeconds").and.callThrough();

        compiledScope.shown = 300;
        compiledScope.$digest();
        compiledScope.save();
        expect(_alerts.showMessage).toHaveBeenCalled();
        expect(_TimeService.convertToSeconds).toHaveBeenCalled();
        expect(_TimeService.newTimeFormatting).toHaveBeenCalled();
    });
});