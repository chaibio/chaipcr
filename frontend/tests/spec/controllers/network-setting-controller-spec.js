describe("Testing NetworkSettingController", function() {

    var NetworkSettingController, _$scope, _$rootScope, _User, _$state, _NetworkSettingsService, 
    _$interval, _$controller;

    beforeEach(function() {
        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _$rootScope = $injector.get('$rootScope');
            _User = $injector.get('User');
            _NetworkSettingsService = $injector.get('NetworkSettingsService');
            _$interval = $injector.get('$interval');
            _$scope = _$rootScope.$new();
            _$controller = $injector.get('$controller');;
            httpMock = $injector.get('$httpBackend');

            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            NetworkSettingController = _$controller('NetworkSettingController', {
                $scope: _$scope
            });

        });
        
    });

    it("It should test initial $scope values", function() {
        
        console.log(_NetworkSettingsService);
        expect(_$scope.wifiNetworks).toEqual(jasmine.any(Object));
        expect(_$scope.currentWifiSettings).toEqual(jasmine.any(Object));
        expect(_$scope.ethernetSettings).toEqual(jasmine.any(Object));
        expect(_$scope.wirelessError).toEqual(false);
        expect(_$scope.macAddress).toEqual(null);
        expect(_$scope.userSettings).toEqual(jasmine.any(Object));
        expect(_$scope.wifiNetworkStatus).toEqual(_$scope.userSettings.wifiSwitchOn);

    });

    it("It should test initial $scope", function() {

        $.jStorage.set("userNetworkSettings", {
            wifiSwitchOn: true
        });

        spyOn(_NetworkSettingsService, "getSettings");

        NetworkSettingController = _$controller('NetworkSettingController', {
            $scope: _$scope
        });

        expect(_NetworkSettingsService.getSettings).toHaveBeenCalled();

    });

    it("It should test initial $scope wifiSwitchOn is false", function() {

        $.jStorage.set("userNetworkSettings", {
            wifiSwitchOn: false
        });

        spyOn(_NetworkSettingsService, "getSettings");

        NetworkSettingController = _$controller('NetworkSettingController', {
            $scope: _$scope
        });

        expect(_NetworkSettingsService.getSettings).not.toHaveBeenCalled();

    });

    it("It should test new_wifi_result event on scope", function() {

        _NetworkSettingsService.connectedWifiNetwork = "Chai";
        _$scope.$broadcast('new_wifi_result');
        expect(_$scope.currentWifiSettings).toEqual(_NetworkSettingsService.connectedWifiNetwork);
        expect(_$scope.wirelessError).toEqual(false);
    });

    it("It should test ethernet_detected event on scope", function() {

        _NetworkSettingsService.connectedEthernet = "ChaiEther";

        _$scope.$broadcast('ethernet_detected');

        expect(_$scope.ethernetSettings).toEqual(_NetworkSettingsService.connectedEthernet);
    });

    it("It should test wifi_adapter_error event", function() {

        spyOn(_$scope, "whenNoWifiAdapter").and.returnValue({});

        _$rootScope.$broadcast('wifi_adapter_error');

        expect(_$scope.whenNoWifiAdapter).toHaveBeenCalled();
    });

    it("It should test wifiNetworkStatus change to true", function() {

        _$scope.userSettings = {
            wifiSwitchOn: true
        };

        spyOn(_$scope, "turnOnWifi");
        _$scope.wirelessError = false;
        _$scope.wifiNetworkStatus = false;
        
        

        _NetworkSettingsService.stopInterval = function() {

        };

        spyOn(_$scope, "turnOffWifi").and.returnValue({});
        spyOn(_NetworkSettingsService, "stopInterval");

        _$scope.$digest();
    
        expect(_$scope.turnOffWifi).toHaveBeenCalled();
        expect(_NetworkSettingsService.stopInterval).toHaveBeenCalled();
    });

    it("It should test wifiNetworkStatus change to false", function() {

        _$scope.userSettings = {
            wifiSwitchOn: false
        };

        spyOn(_$scope, "turnOnWifi");
        _$scope.wirelessError = false;
        _$scope.wifiNetworkStatus = true;
        
        spyOn(_$scope, "turnOffWifi").and.returnValue({});
        
        _$scope.$digest();
    
        expect(_$scope.turnOnWifi).toHaveBeenCalled();
    });

    it("It should test wifiNetworkStatus change when wirelessError is true", function() {

        _$scope.userSettings = {
            wifiSwitchOn: false
        };

        spyOn(_$scope, "turnOnWifi");
        _$scope.wirelessError = true;
        _$scope.wifiNetworkStatus = true;
        
        spyOn(_$scope, "turnOffWifi").and.returnValue({});
        
        _$scope.$digest();
    
        expect(_$scope.turnOnWifi).not.toHaveBeenCalled();
    });

    it("It should test wifiNetworkStatus change to false, when wifiSwitchOn is already true [its unlikely]", function() {

        _$scope.userSettings = {
            wifiSwitchOn: true
        };

        spyOn(_$scope, "turnOnWifi");
        _$scope.wirelessError = false;
        _$scope.wifiNetworkStatus = true;
        
        spyOn(_$scope, "turnOffWifi").and.returnValue({});
        
        _$scope.$digest();
    
        expect(_$scope.turnOffWifi).not.toHaveBeenCalled();
    });

});