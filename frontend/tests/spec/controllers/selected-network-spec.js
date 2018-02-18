describe("Testing selectedNetwork", function() {

    var _$scope, _$stateParams, _User, 
    _$state, _NetworkSettingsService, _$timeout, 
    _$window, selectedNetwork, _$controller;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
            $provide.value('$stateParams', {
                id: 100
            });

            $provide.value('$state', {
                params: {
                    name: "Jossie"
                }
            });
        });

        inject(function($injector) {
            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            _User = $injector.get('User');
            _$state = $injector.get('$state');
            _NetworkSettingsService = $injector.get('NetworkSettingsService');
            _$timeout = $injector.get('$timeout');
            _$window = $injector.get('$window');
            _$controller = $injector.get('$controller');

            selectedNetwork = _$controller('selectedNetwork', {
                $scope: _$scope
            });

        });
    });

    it("It should test initial values", function() {

        expect(_$scope.name).toEqual("Jossie");
        expect(_$scope.buttonValue).toEqual("CONNECT");
        expect(_$scope.IamConnected).toEqual(false);
        expect(_$scope.statusMessage).toEqual("");
        expect(_$scope.currentNetwork).toEqual(jasmine.any(Object));
        expect(_$scope.autoSetting).toEqual("auto");
        expect(_$scope.connectedSsid).toEqual("");
        expect(_$scope.selectedWifiNow).toEqual(null);
        expect(_$scope.wifiNetworkType).toEqual(null);
        expect(_$scope.editEthernetData).toEqual(jasmine.any(Object));
    });

});