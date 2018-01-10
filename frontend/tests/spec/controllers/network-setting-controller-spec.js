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
            _$controller = $injector.get('$controller');
            _$state = $injector.get('$state');
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

    it("It should test wifi_adapter_reconnected event", function() {

        var evt = {};
        var wifiData = {
            state: {
                macAddress: "100:1w:dd:dd:300"
            }
        };

        spyOn(_$scope, "init").and.returnValue({});

        _$scope.$broadcast("wifi_adapter_reconnected", wifiData);

        expect(_$scope.wifiNetworkStatus).toEqual(true);
        expect(_$scope.wirelessError).toEqual(false);
        expect(_$scope.macAddress).toEqual(wifiData.state.macAddress);
        expect(_$scope.init).toHaveBeenCalled();
    });

    it("It should test wifi_stopped event", function() {

        _$scope.$broadcast("wifi_stopped");
        expect(_$scope.wifiNetworks.ssid).toEqual(undefined);
    });

    it("It should test whenNoWifiAdapter method", function() {

        _NetworkSettingsService.wirelessErrorData = "no_wifi_adapter";
        _$scope.whenNoWifiAdapter();

        expect(_$scope.wirelessError).toEqual(true);
        expect(_$scope.wifiNetworkStatus).toEqual(false);
        expect(_$scope.wirelessErrorData).toEqual("no_wifi_adapter");
        expect(_$scope.wifiNetworks.ssid).toEqual(undefined);
    });

    it("It should test turnOffWifi method", function() {

        _NetworkSettingsService.stop = function() {
            var result;
            return {
                then: function(callback) {
                    callback(result);
                }
            };
        };

        spyOn(_NetworkSettingsService, "stop").and.callThrough();
        spyOn(_$state, "go").and.returnValue(true);

        _$scope.turnOffWifi();

        expect(_NetworkSettingsService.stop).toHaveBeenCalled();
        expect(_$state.go).toHaveBeenCalled();
    });

    it("It should test turnOffWifi error callback", function() {

        _NetworkSettingsService.stop = function() {
            var result = {}, successCallback = null;
            return {
                then: function( successCallback ,errorCallback) {
                    errorCallback(result);
                }
            };
        };

        spyOn(_NetworkSettingsService, "stop").and.callThrough();
        spyOn(_$state, "go").and.returnValue(true);

        _$scope.turnOffWifi();

        expect(_NetworkSettingsService.stop).toHaveBeenCalled();
        expect(_$state.go).not.toHaveBeenCalled(); 

    });

    it("It should test turnOnWifi method", function() {

        _NetworkSettingsService.restart = function() {

            var successArg;
            return {
                then: function(success, error) {
                    if(typeof(success) === 'function') {
                        success(successArg);
                    }
                }
            };
        };

        spyOn(_$scope, "init");

        _$scope.turnOnWifi();

        expect(_$scope.init).toHaveBeenCalled();

    });

    it("It should test turnOnWifi method when restart returns error", function() {

        _NetworkSettingsService.restart = function() {

            var successArg, errorArg;
            return {
                then: function(success, error) {
                    //if(typeof(success) === 'function') {
                      //  success(successArg);
                    //} else 
                    if(typeof(error) === 'function') {
                        error(errorArg); 
                    }
                }
            };
        };

        _NetworkSettingsService.processOnError = function() {

        };

        spyOn(_NetworkSettingsService, "processOnError");

        _$scope.turnOnWifi();

        expect(_NetworkSettingsService.processOnError).toHaveBeenCalled();

    });

    it("It should test findWifiNetworks method", function() {

        _NetworkSettingsService.wirelessError = false;
        _$scope.userSettings = {
            wifiSwitchOn: true
        };

        _NetworkSettingsService.getWifiNetworks = function() {
            
            var result = {
                data: {
                    scan_result: [
                        {
                            ssid: "chai"
                        },
                        {
                            ssid: "chaiBio"
                        }
                    ]
                }
            };

            return {
                then: function(callback) {
                    callback(result);
                }
            };

            
        };

        _$scope.findWifiNetworks();
        expect(_$scope.wifiNetworks[0].ssid).toEqual("chai");
    });

    it("It should test findWifiNetworks method, when there is wirelessError", function() {

        _NetworkSettingsService.wirelessError = true;
        _$scope.userSettings = {
            wifiSwitchOn: true
        };

        _NetworkSettingsService.getWifiNetworks = function() {
            
        };

        spyOn(_NetworkSettingsService, "getWifiNetworks");

        _$scope.findWifiNetworks();

        expect(_NetworkSettingsService.getWifiNetworks).not.toHaveBeenCalled();
    });

    it("It should test init method when wifi switch is off", function() {

        _NetworkSettingsService.getEthernetStatus = function() {};

        spyOn(_NetworkSettingsService, "getEthernetStatus");

        _NetworkSettingsService.wirelessError = true;

        spyOn(_$scope, "whenNoWifiAdapter");

        _NetworkSettingsService.getSettings = function() {};

        spyOn(_NetworkSettingsService, "getSettings");

        _$scope.init();

        expect(_NetworkSettingsService.getEthernetStatus).toHaveBeenCalled();
        expect(_$scope.whenNoWifiAdapter).toHaveBeenCalled();
        expect(_NetworkSettingsService.getSettings).not.toHaveBeenCalled();
    });

    it("It should test init method, when wifi switch is on", function() {

        _NetworkSettingsService.getEthernetStatus = function() {};

        spyOn(_NetworkSettingsService, "getEthernetStatus");

        _NetworkSettingsService.wirelessError = false;

        _NetworkSettingsService.intervalKey = null;

        spyOn(_$scope, "whenNoWifiAdapter");

        spyOn(_$scope, "findWifiNetworks");

        _NetworkSettingsService.getSettings = function() {};

        spyOn(_NetworkSettingsService, "getSettings");

        _$scope.userSettings = {
            wifiSwitchOn: true
        };

        _$scope.init();

        expect(_NetworkSettingsService.getEthernetStatus).toHaveBeenCalled();
        expect(_NetworkSettingsService.getSettings).toHaveBeenCalled();
        expect(_$scope.whenNoWifiAdapter).not.toHaveBeenCalled();
        expect(_$scope.findWifiNetworks).toHaveBeenCalled();
    });

    it("It should test init method, when wifi switch is on", function() {

        _NetworkSettingsService.getEthernetStatus = function() {};

        spyOn(_NetworkSettingsService, "getEthernetStatus");

        _NetworkSettingsService.wirelessError = false;

        _NetworkSettingsService.intervalKey = null;

        spyOn(_$scope, "whenNoWifiAdapter");

        spyOn(_$scope, "findWifiNetworks");

        _NetworkSettingsService.getSettings = function() {
            _NetworkSettingsService.wirelessError = true;
        };

        spyOn(_NetworkSettingsService, "getSettings").and.callThrough();

        _$scope.userSettings = {
            wifiSwitchOn: true
        };
        _$scope.macAddress = null;

        _$scope.init();

        expect(_NetworkSettingsService.getEthernetStatus).toHaveBeenCalled();
        expect(_NetworkSettingsService.getSettings).toHaveBeenCalled();
        expect(_$scope.whenNoWifiAdapter).not.toHaveBeenCalled();
        expect(_$scope.findWifiNetworks).toHaveBeenCalled();
    });



});