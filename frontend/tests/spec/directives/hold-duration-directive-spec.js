describe("Testing holdDuration directive", function() {

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

            var elem = angular.element('<hold-duration caption="Hold Duration" help-text="[0:00-5:00]" reading="20" pause="! step.pause"></hold-duration>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.edit).toEqual(false);
        expect(compiledScope.delta).toEqual(true);
    });

    it("It should test change in reading", function() {

        spyOn(_TimeService, "newTimeFormatting").and.returnValue();
        compiledScope.reading = 30;
        compiledScope.$digest();
        expect(_TimeService.newTimeFormatting).toHaveBeenCalled();
    });

    it("It should test change in pause", function() {

        compiledScope.pause = false;
        compiledScope.$digest();
        expect(compiledScope.edit).toEqual(false);
    });

    it("It should test change in edit", function() {

        spyOn($.fn, "animate").and.returnValue(true);
        compiledScope.edit = true;
        compiledScope.$digest();
        expect($.fn.animate).toHaveBeenCalledWith({left: 100}, 200);
    });

    it("It should test change in edit when edit is false", function() {

        spyOn($.fn, "animate").and.returnValue(true);
        compiledScope.edit = "bn";
        compiledScope.$digest();
        compiledScope.edit = false;
        compiledScope.$digest();
        expect($.fn.animate).toHaveBeenCalledWith({left: 0}, 200);
    });

    it("It should test ifLastStep method", function() {
        compiledScope.$parent = {
            fabricStep: {
                circle: {
                    next: null
                }
            }
        };

        compiledScope.$digest();
        var retVal = compiledScope.ifLastStep();
        expect(retVal).toEqual(true);
    });

    it("It should test editAndFocus method", function() {

        spyOn(_TimeService, "convertToSeconds").and.returnValue(100);
        compiledScope.editAndFocus();
        expect(_TimeService.convertToSeconds).toHaveBeenCalled();
        expect(compiledScope.edit).toEqual(true);
    });

    it("It should test save method", function() {

        spyOn(_TimeService, "convertToSeconds").and.returnValue("NaN");
        spyOn(_TimeService, "newTimeFormatting").and.returnValue(10);

        compiledScope.save();

        expect(_TimeService.convertToSeconds).toHaveBeenCalled();
        expect(_TimeService.newTimeFormatting).toHaveBeenCalled();
        expect(compiledScope.shown).toEqual(10);
    });

    it("It should test save method when !isNaN(newHoldTime) && scope.reading != newHoldTime and when value is negative", function() {

        spyOn(_TimeService, "convertToSeconds").and.returnValue(-50);
        spyOn(_TimeService, "newTimeFormatting").and.returnValue(10);
        spyOn(_alerts, "showMessage").and.returnValue();

        compiledScope.reading = 24;

        compiledScope.$digest();

        compiledScope.save();

        expect(_TimeService.convertToSeconds).toHaveBeenCalled();
        expect(_alerts.showMessage).toHaveBeenCalled();

    });

});