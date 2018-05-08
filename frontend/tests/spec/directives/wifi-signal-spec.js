describe("Testing wifiSignal dirctive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus, _TimeService, _addStageService, _$state;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
            /*$provide.value('$state', {
                is: function() {
                    return true;
                }
            });*/
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
            _$state = $injector.get('$state');
            _$state.is = function() {
                return true;
            };
            _$state.params = {
                name: "chai"
            };
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

            var elem = angular.element('<wifi-signal ssid="chai" quality="100"></wifi-signal>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {
        console.log(compiledScope);
        //Quality provided is 100
        expect(compiledScope.arc4Signal).toEqual(true);
        expect(compiledScope.arc3Signal).toEqual(true);
        expect(compiledScope.arc2Signal).toEqual(true);
        expect(compiledScope.arc1Signal).toEqual(true);
        expect(compiledScope.selected).toEqual(true);
    });

    it("It should test change in quality", function() {

        spyOn(compiledScope, "rerender").and.returnValue(true);

        compiledScope.quality = 50;
        compiledScope.$digest();

        expect(compiledScope.rerender).toHaveBeenCalled();
    });

    it("It should test rerender method when quality 1s 100", function() {
        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = false;
        compiledScope.arc3Signal = false;
        compiledScope.arc4Signal = false;
        compiledScope.$digest();

        var quality = 100;
        
        compiledScope.rerender(quality);

        compiledScope.arc1Signal = true;
        compiledScope.arc2Signal = true;
        compiledScope.arc3Signal = true;
        compiledScope.arc4Signal = true;

    });

    it("It should test rerender method when quality 1s 70", function() {
        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = false;
        compiledScope.arc3Signal = false;
        compiledScope.arc4Signal = false;
        compiledScope.$digest();

        var quality = 70;
        
        compiledScope.rerender(quality);

        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = true;
        compiledScope.arc3Signal = true;
        compiledScope.arc4Signal = true;

    });

    it("It should test rerender method when quality 1s 40", function() {
        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = false;
        compiledScope.arc3Signal = false;
        compiledScope.arc4Signal = false;
        compiledScope.$digest();

        var quality = 40;
        
        compiledScope.rerender(quality);

        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = false;
        compiledScope.arc3Signal = true;
        compiledScope.arc4Signal = true;

    });

    it("It should test rerender method when quality 1s 20", function() {
        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = false;
        compiledScope.arc3Signal = false;
        compiledScope.arc4Signal = false;
        compiledScope.$digest();

        var quality = 20;
        
        compiledScope.rerender(quality);

        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = false;
        compiledScope.arc3Signal = false;
        compiledScope.arc4Signal = true;

    });

    it("It should test rerender method when quality 1s 0", function() {
        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = false;
        compiledScope.arc3Signal = false;
        compiledScope.arc4Signal = false;
        compiledScope.$digest();

        var quality = 0;
        
        compiledScope.rerender(quality);

        compiledScope.arc1Signal = false;
        compiledScope.arc2Signal = false;
        compiledScope.arc3Signal = false;
        compiledScope.arc4Signal = false;

    });

});