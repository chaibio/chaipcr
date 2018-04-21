describe("Testing summaryMode", function() {

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

            var elem = angular.element('<summary-mode></summary-mode>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.scope();
            
        });
    });

    it("It should test change in summaryMode === false", function() {

        spyOn($.fn, "animate").and.returnValue(true);

        compiledScope.summaryMode = false;
        compiledScope.$digest();

        expect($.fn.animate).toHaveBeenCalled();
    });

    it("It should test summaryMode === true", function() {

        compiledScope.protocol = {
            protocol: {
                estimate_duration: "calculating ....!"
            }
        };
        _ExperimentLoader.getExperiment = function() {
            return {
                then: function(callback) {
                    var data = {
                        experiment: {
                            protocol: {
                                estimate_duration: "1:00:00"
                            }
                        }
                    };

                    callback(data);
                }
            };
        };

        spyOn(_ExperimentLoader, "getExperiment").and.callThrough();
        spyOn($.fn, "width").and.returnValue(true);
        spyOn($.fn, "eq").and.returnValue({
            css: function() {
                return "10px";
            }
        });
        spyOn($.fn, "animate").and.returnValue(true);

        compiledScope.summaryMode = true;
        compiledScope.$digest();

        expect(compiledScope.protocol.protocol.estimate_duration).toEqual("1:00:00");
        expect(_ExperimentLoader.getExperiment).toHaveBeenCalled();
        expect($.fn.width).toHaveBeenCalled();
        expect($.fn.eq).toHaveBeenCalled();
        expect($.fn.animate).toHaveBeenCalled();
    });
});