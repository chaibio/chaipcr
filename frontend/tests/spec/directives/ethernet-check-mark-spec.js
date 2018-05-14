describe("Testing ethernetCheckMark", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus, _TimeService, _addStageService, _$state, _NetworkSettingsService, _editModeService;

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
            _editModeService = $injector.get('editModeService');
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

            var elem = angular.element('<ethernet-check-mark name="ethernet"></ethernet-check-mark>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {
        
        expect(compiledScope.connected).toEqual(false);
    });

    it("It should test ethernet_detected ", function() {
        
        spyOn(compiledScope, "verify").and.returnValue(true);
        compiledScope.$broadcast("ethernet_detected");
        expect(compiledScope.verify).toHaveBeenCalled();

    });

    it("It should test verify method", function() {
        
        _NetworkSettingsService.connectedEthernet = {
            settings: {

            }
        };
        
        compiledScope.verify();

        expect(compiledScope.connected).toEqual(true);
    });
});