describe("Testing summaryModeItem", function() {

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

            var elem = angular.element('<summary-mode-item caption="Stages Step Chai Cool kwel" reading="10"></summary-mode-item>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.scope();
            
        });
    });

    it("It should test initial values", function() {

        compiledScope.delta = true;
        compiledScope.date = false;
    });

    it("It should test when caption === 'Created on'", function() {

        var elem = angular.element('<summary-mode-item caption="Created on" reading="10"></summary-mode-item>');
        var compiled = _$compile(elem)(_$scope);
        _$scope.show = true;
        _$scope.$digest();
        compiledScope = compiled.isolateScope();

        expect(compiledScope.date).toEqual(true);
    });

    it("It should test when caption === 'Run on'", function() {

        var elem = angular.element('<summary-mode-item caption="Run on" reading="10"></summary-mode-item>');
        var compiled = _$compile(elem)(_$scope);
        _$scope.show = true;
        _$scope.$digest();
        compiledScope = compiled.isolateScope();

        expect(compiledScope.date).toEqual(true);
    });


});