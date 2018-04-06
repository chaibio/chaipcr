describe("Testing checkMark directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _NetworkSettingsService, _$state, _$timeout;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            _$compile = $injector.get('$compile');
            _NetworkSettingsService = $injector.get('NetworkSettingsService');
            _$state = $injector.get('$state');
            _$timeout = $injector.get('$timeout');
            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");

            
            var elem = angular.element('<check-mark func="changeDeltaTime" delta="10" data="15"></check-mark>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
        });
    });

});