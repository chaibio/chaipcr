describe("Testing supportAccess", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus, _TimeService, _addStageService, _supportAccessService;

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
            _supportAccessService = $injector.get('supportAccessService');

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

            var elem = angular.element('<support-access></support-access>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.scope();
        });
    });

    it("It should test getAccess method and success callback", function() {

        _supportAccessService.accessSupport = function() {
            return {
                then: function(successCallback, errorCallback) {
                    var data = {

                    };
                    successCallback(data);
                }
            };
        };

        spyOn(_supportAccessService, "accessSupport").and.callThrough();
        spyOn(compiledScope, "getMessage").and.returnValue(true);

        compiledScope.getAccess();

        expect(_supportAccessService.accessSupport).toHaveBeenCalled();
        expect(compiledScope.getMessage).toHaveBeenCalled();
        expect(compiledScope.message).toEqual("We have successfully enabled support access. Thank you.");

    });

    it("It should test getAccess method and error callback", function() {

        _supportAccessService.accessSupport = function() {
            return {
                then: function(successCallback, errorCallback) {
                    var data = {

                    };
                    errorCallback(data);
                }
            };
        };

        spyOn(_supportAccessService, "accessSupport").and.callThrough();
        spyOn(compiledScope, "getMessage").and.returnValue(true);

        compiledScope.getAccess();

        expect(_supportAccessService.accessSupport).toHaveBeenCalled();
        expect(compiledScope.getMessage).toHaveBeenCalled();
        expect(compiledScope.message).toEqual("We could not enable support access at this moment. Please try again later.");
    });

    it("It should test getMessage method", function() {

        spyOn(_$uibModal, "open").and.returnValue(true);

        compiledScope.getMessage();

        expect(_$uibModal.open).toHaveBeenCalled();
    });
    
});