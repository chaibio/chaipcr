describe("Testing wifi-toggle", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus, _TimeService, _addStageService, _$state, _NetworkSettingsService;

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

            _NetworkSettingsService = $injector.get('NetworkSettingsService');

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

            var elem = angular.element('<wifi-toggle wireless-status="false" no-wifi-adapter="false"></wifi-toggle>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {
        expect(compiledScope.show).toEqual(true);
        expect(compiledScope.inProgress).toEqual(false);
    });

    it("It should test wirelessStatus", function() {

        spyOn(compiledScope, "configureSwitch").and.returnValue(true);
        compiledScope.wirelessStatus = true;
        compiledScope.$digest();
        expect(compiledScope.inProgress).toEqual(false);
        expect(compiledScope.configureSwitch).toHaveBeenCalled();
    });

    it("It should test inProgress $watch inProgress is true", function() {
        
        compiledScope.dragElem = {
            draggable: function() {
                return true;
            }
        };

        spyOn(compiledScope.dragElem, "draggable").and.returnValue(true);
        compiledScope.inProgress = true;
        compiledScope.$digest();
        expect(compiledScope.dragElem.draggable).toHaveBeenCalledWith('disable');
    });

    it("It should test inProgress $watch when inProgress is false", function() {
        
        compiledScope.dragElem = {
            draggable: function() {
                return true;
            }
        };

        spyOn(compiledScope.dragElem, "draggable").and.returnValue(true);
        compiledScope.inProgress = true;
        compiledScope.$digest();
        compiledScope.inProgress = false;
        compiledScope.$digest();
        expect(compiledScope.dragElem.draggable).toHaveBeenCalledWith('enable');
    });

    it("It should test noDevice $watch when noDevice is true", function() {

        compiledScope.dragElem = {
            draggable: function() {
                return true;
            }
        };

        spyOn(compiledScope.dragElem, "draggable").and.returnValue(true);
        spyOn(compiledScope, "changeState").and.returnValue(true);
        compiledScope.noDevice =true;
        compiledScope.$digest();
        expect(compiledScope.dragElem.draggable).toHaveBeenCalledWith('disable');
        expect(compiledScope.changeState).toHaveBeenCalled();
    });

    it("It should test noDevice $watch when noDevice is false", function() {

        compiledScope.dragElem = {
            draggable: function() {
                return true;
            }
        };

        spyOn(compiledScope.dragElem, "draggable").and.returnValue(true);
        spyOn(compiledScope, "changeState").and.returnValue(true);
        compiledScope.noDevice =true;
        compiledScope.$digest();
        compiledScope.noDevice =false;
        compiledScope.$digest();

        expect(compiledScope.dragElem.draggable).toHaveBeenCalledWith('enable');
    });

    it("It should test wifi_restarted", function() {

        compiledScope.$broadcast("wifi_restarted");
        compiledScope.$digest();
        expect(compiledScope.inProgress).toEqual(false);
    });

    it("It should test wifi_stopped", function() {

        compiledScope.$broadcast('wifi_stopped');
        compiledScope.$digest();
        expect(compiledScope.inProgress).toEqual(false);
        expect(compiledScope.wirelessStatus).toEqual(false);
    });

    it("It should test clickHandler method", function() {

        spyOn(compiledScope, "sendData").and.returnValue(true);
        compiledScope.inProgress = false;
        compiledScope.$digest();
        compiledScope.clickHandler();
        expect(compiledScope.sendData).toHaveBeenCalled();
    });
});