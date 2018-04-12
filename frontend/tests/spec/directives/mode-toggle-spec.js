describe("Testing modeToggle ", function() {
    
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

            var elem = angular.element('<mode-toggle data="$parent.autoSetting"></mode-toggle>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.show).toEqual(true);
    });

    it("It should test $watch data test", function() {

        spyOn(compiledScope, "configureSwitch").and.returnValue(true);
        compiledScope.data = "data";
        compiledScope.$digest();

        expect(compiledScope.configureSwitch).toHaveBeenCalledWith("data");
    });

    it("It should test clickHandler method", function() {

        spyOn(compiledScope, "sendData").and.returnValue(true);

        compiledScope.clickHandler();

        expect(compiledScope.sendData).toHaveBeenCalledWith();
    });

    it("It should test configureSwitch method", function() {

        var val = "auto";
        
        spyOn(angular, "element").and.returnValue({
            parent: function() {
                return {
                    css: function() {

                    }
                };
            },

            children: function() {
                return {
                    css: function() {

                    }
                };
            },

            animate: function() {

            }
        });

        compiledScope.configureSwitch(val);

        expect(angular.element).toHaveBeenCalled();

    });

    it("It should test configureSwitch method", function() {

        var val = "not auto";
        
        spyOn(angular, "element").and.returnValue({
            parent: function() {
                return {
                    css: function() {

                    }
                };
            },

            children: function() {
                return {
                    css: function() {

                    }
                };
            },

            animate: function() {
                
            }
        });

        compiledScope.configureSwitch(val);

        expect(angular.element).toHaveBeenCalled();

    });

    it("It should test processMovement method", function() {

        var pos = 3, val = 10;
        spyOn($.fn, "css").and.returnValue(true);
        spyOn(compiledScope, "sendData").and.returnValue(true);
        compiledScope.data = 10;
        compiledScope.$digest();

        compiledScope.processMovement(pos, val);

        expect($.fn.css).toHaveBeenCalledWith("left", "1px");
        expect(compiledScope.sendData).not.toHaveBeenCalled();
    });

    it("It should test processMovement method", function() {

        var pos = 8, val = 14;
        spyOn($.fn, "css").and.returnValue(true);
        spyOn(compiledScope, "sendData").and.returnValue(true);
        compiledScope.data = 10;
        compiledScope.$digest();

        compiledScope.processMovement(pos, val);

        expect($.fn.css).toHaveBeenCalledWith("left", "11px");
        expect(compiledScope.sendData).toHaveBeenCalled();
    });

    it("It should test sendData method when data manual", function() {

        compiledScope.data = "manual";
        compiledScope.$digest();

        compiledScope.sendData();

        expect(compiledScope.data).toEqual("auto");
    });

    it("It should test sendData method when data not manual", function() {

        compiledScope.data = "not manual";
        compiledScope.$digest();

        compiledScope.sendData();

        expect(compiledScope.data).toEqual("manual");
    });
});