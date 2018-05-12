describe("Testing version-info-directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus, _TimeService, _addStageService, _$state, _Status, _Device;

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
            _$state = $injector.get('$state');
            _popupStatus = $injector.get('popupStatus');
            httpMock = $injector.get('$httpBackend');
            _TimeService = $injector.get('TimeService');
            _addStageService = $injector.get('addStageService');
            _Status = $injector.get('Status');
            _Device = $injector.get('Device');

            _$state.is = function() {
                return true;
            };

            _$state.params = {
                name: "wow"
            };

            _Device.getVersion = function() {

                var data = {
                    version: "1.2"
                };
                return {
                    then: function(callback) {
                        callback(data);
                    }
                };
            };

            _Device.checkForUpdate = function() {
            
                var is_available = "available";
                return {
                    then: function(callback) {
                        callback();
                    }
                };
            };
            

            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");
            httpMock.whenGET("/device").respond("NOTHING");

            var stage = {
                auto_delta: true
            };

            var step = {
                delta_duration_s: 10,
                hold_time: 20,
                pause: true
            };

            var elem = angular.element('<version-info></version-info>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.update_available).toEqual("unavailable");
        expect(compiledScope.data.version).toEqual("1.2");
    });

    it("It should test status:data:updated", function() {
        compiledScope.$broadcast('status:data:updated', {device: {
            update_available: "available"
        }, });

        expect(compiledScope.update_available).toEqual("available");

    });

    it("It should test updateSoftware method", function() {

        _Device.updateSoftware = function() {

        };

        spyOn(_Device, "updateSoftware").and.returnValue(true);

        compiledScope.updateSoftware();

        expect(_Device.updateSoftware).toHaveBeenCalled();
    });

    it("It should test openUpdateModal method", function() {

        _Device.openUpdateModal = function() {

        };

        spyOn(_Device, "openUpdateModal").and.returnValue(true);

        compiledScope.openUpdateModal();

        expect(_Device.openUpdateModal).toHaveBeenCalled();
    });

    it("It should test checkForUpdates then", function() {

        _Device.checkForUpdate = function() {
            
            var is_available = "available";
            return {
                then: function(callback) {
                    callback(is_available);
                },
                catch: function(callback) {
                    callback();
                },

                finally: function(callback) {
                    callback();
                }
            };
        };

        spyOn(_Device, "checkForUpdate").and.callThrough();
        spyOn(compiledScope, "openUpdateModal").and.returnValue(true);

        compiledScope.checkForUpdates();

        expect(_Device.checkForUpdate).toHaveBeenCalled();
        expect(compiledScope.openUpdateModal).toHaveBeenCalled();
    });
});