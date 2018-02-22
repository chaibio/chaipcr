describe("Testing selectedNetwork", function() {

    var _$scope, _$stateParams, _User, 
    _$state, _NetworkSettingsService, _$timeout, 
    _$window, selectedNetwork, _$controller, 
    httpMock;

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
            httpMock = $injector.get('$httpBackend');

            //_NetworkSettingsService
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.expectPUT("http://localhost:8000/network/eth0").respond({
                status: {
                    
                }
            });
 
            selectedNetwork = _$controller('selectedNetwork', {
                $scope: _$scope
            });

        });
    });

    it("It should test initial values", function() {

        //spyOn(_$scope, "init");
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
        //expect(_$scope.init).toHaveBeenCalled();
    });

    it("It should test autoSetting $watch when 'manual'", function() {

        _$scope.autoSetting = "manual";
         _$scope.$digest();
        expect(_$scope.buttonValue).toEqual("SAVE CHANGES");
       
    });

    it("It should test autoSetting $watch when 'auto'", function() {

        _$scope.currentNetwork = {
            settings: {
                type: "static"
            }
        };
        _$scope.autoSetting = "auto";
        

        spyOn(_$scope, "changeToAutomatic").and.callFake(function() {
            return true;
        });
        _$scope.$digest();

        expect(_$scope.buttonValue).toEqual("CONNECT");
        expect(_$scope.changeToAutomatic).toHaveBeenCalled();
    });

    it("It should test ethernet_detected $on", function() {

        spyOn(_$scope, "init");
        _$scope.$broadcast("ethernet_detected");
        expect(_$scope.init).toHaveBeenCalled();
    });

    it("It should test new_wifi_result $on and connected", function() {

        _$scope.connectedSsid = "Chai";
        _$state.params = {
            name: "Chai"
        };
        _NetworkSettingsService.connectedWifiNetwork = {

            state: {
                status: "connected"
            },
            settings: {
                'dns-nameservers': "chai net",
                'wpa-ssid': 'Chai',
                'wireless_essid': 'Bio'
            }
        };

        _$scope.$broadcast('new_wifi_result');

        expect(_$scope.statusMessage).toEqual("");
        expect(_$scope.currentNetwork.settings).toEqual(jasmine.any(Object));
        expect(_$scope.editEthernetData.dns_nameservers).toEqual("chai");
    });

    it("It should test new_wifi_result $on and not connected", function() {
        
         _$scope.connectedSsid = "Chai";
        _$state.params = {
            name: "Chai"
        };
        _NetworkSettingsService.connectedWifiNetwork = {

            state: {
                status: "connecting"
            },
            settings: {
                'dns-nameservers': "chai net",
                'wpa-ssid': 'Chai',
                'wireless_essid': 'Bio'
            }
        };

        spyOn(_$scope, "configureAsStatus").and.callFake(function() {
            return true;
        });

        _$scope.$broadcast('new_wifi_result');

        expect(_$scope.configureAsStatus).toHaveBeenCalled();
    });

    it("It should test updateConnectedWifi method, when fifi has connecting status", function() {

         _NetworkSettingsService.connectedWifiNetwork = {

            state: {
                status: "connecting"
            },
            settings: {
                'dns-nameservers': "chai net",
                'wpa-ssid': 'ChaiBio',
                'wireless_essid': 'Bio',

            }
        };

        _$state.params = {
            name: "ChaiBio"
        };

        _$scope.updateConnectedWifi("wpa-ssid");

        expect(_$scope.buttonValue).toEqual("CONNECTING");
    });

    it("It should test updateConnectedWifi method, when fifi has connected status", function() {

         _NetworkSettingsService.connectedWifiNetwork = {

            state: {
                status: "connected"
            },
            settings: {
                'dns-nameservers': "chai net",
                'wpa-ssid': 'ChaiBio',
                'wireless_essid': 'Bio',
            }
        };

        _$state.params = {
            name: "ChaiBio"
        };

        _$scope.updateConnectedWifi("wpa-ssid");

        expect(_$scope.IamConnected).toEqual(true);
        expect(_$scope.editEthernetData.dns_nameservers).toEqual('chai');
    });

    it("It should test connectWifi method", function() {

        _NetworkSettingsService.connectWifi = function() {
            return {
                then: function(callback) {
                    callback();
                }
            };
        };

        spyOn(_NetworkSettingsService, "connectWifi").and.callThrough();

        _$scope.connectWifi();
        
        expect(_$scope.statusMessage).toEqual("");
        expect(_$scope.buttonValue).toEqual("CONNECTING");
        expect(_NetworkSettingsService.connectWifi).toHaveBeenCalled();
    });

    it("It should test connectWifi metgod when there is error connecting", function() {

        _NetworkSettingsService.connectWifi = function() {
            return {
                then: function(callback, errorCallback) {
                    errorCallback();
                }
            };
        };

        spyOn(_NetworkSettingsService, "connectWifi").and.callThrough();

        _$scope.connectWifi();
        
        expect(_NetworkSettingsService.connectWifi).toHaveBeenCalled();
    });

    it("It should test configureAsStatus method, when not_connected", function() {

        var status = "not_connected";
        _$scope.configureAsStatus(status);

        expect(_$scope.buttonValue).toEqual("CONNECT");
        expect(_$scope.statusMessage).toEqual("");
    });

    it("It should test configureAsStatus method, when connecting", function() {

        var status = "connecting";
        _$scope.configureAsStatus(status);

        expect(_$scope.buttonValue).toEqual("CONNECTING");
        expect(_$scope.statusMessage).toEqual("");
    });

    it("It should test configureAsStatus method, when connection_error", function() {

        var status = "connection_error";
        _$scope.configureAsStatus(status);

        expect(_$scope.buttonValue).toEqual("CONNECT");
        expect(_$scope.statusMessage).toEqual("Unable to connect");
    });

    it("It should test configureAsStatus method, when authentication_error", function() {

        var status = "authentication_error";
        _$scope.configureAsStatus(status);

        expect(_$scope.buttonValue).toEqual("CONNECT");
        expect(_$scope.statusMessage).toEqual("Authentication error");
    });

    it("It should test connectEthernet method", function() {

        _NetworkSettingsService.connectToEthernet = function() {
            return {
                then: function(callback) {
                    callback();
                }
            };
        };

        spyOn(_NetworkSettingsService, "getEthernetStatus");
        spyOn(_NetworkSettingsService, "connectToEthernet").and.callThrough();

        _$scope.connectEthernet();

        expect(_$scope.statusMessage).toEqual("");
        expect(_$scope.buttonValue).toEqual("CONNECTING");
        expect(_NetworkSettingsService.getEthernetStatus).toHaveBeenCalled();

    });

    it("It should test connectEthernet method, when connectEthernet returns error", function() {

        _NetworkSettingsService.connectToEthernet = function() {
            return {
                then: function(callback, errorCallback) {
                    errorCallback();
                }
            };
        };

        spyOn(_NetworkSettingsService, "getEthernetStatus");
        spyOn(_NetworkSettingsService, "connectToEthernet").and.callThrough();

        _$scope.connectEthernet();

        expect(_$scope.statusMessage).toEqual("");
        expect(_$scope.buttonValue).toEqual("CONNECTING");
        expect(_NetworkSettingsService.getEthernetStatus).not.toHaveBeenCalled();

    });

    it("It should test goToNewIp method", function() {

        _$scope.editEthernetData = {
            address: "post office"
        };

        _$scope.currentNetwork = {
            settings: {
                type: "dhcp"
            }
        }
        _$scope.$digest();
        
        _$scope.goToNewIp();
        //expect(_$window.location.href).toEqual('http://' + _$scope.editEthernetData.address);
    });

    it("It should test changeToAutomatic method", function() {

        _NetworkSettingsService.changeToAutomatic = function() {
            return {
                then: function(callback) {
                    callback();
                }
            };
        };

        spyOn(_NetworkSettingsService, "changeToAutomatic").and.callThrough();
        spyOn(_NetworkSettingsService, "getEthernetStatus");

        _$scope.changeToAutomatic();

        expect(_NetworkSettingsService.changeToAutomatic).toHaveBeenCalled();
        expect(_NetworkSettingsService.getEthernetStatus).toHaveBeenCalled();
        expect(_$scope.autoSetting).toEqual("auto");
    });

    it("It should test changeToAutomatic method when _NetworkSettingsService.changeToAutomatic returns error", function() {

        _NetworkSettingsService.changeToAutomatic = function() {
            return {
                then: function(callback, errorCallback) {
                    errorCallback();
                }
            };
        };

        spyOn(_NetworkSettingsService, "changeToAutomatic").and.callThrough();
        spyOn(_NetworkSettingsService, "getEthernetStatus");

        _$scope.changeToAutomatic();

        expect(_NetworkSettingsService.changeToAutomatic).toHaveBeenCalled();
        expect(_NetworkSettingsService.getEthernetStatus).not.toHaveBeenCalled();
    });

    it("It should test init method", function() {

        _$scope.selectedWifiNow = {
            encryption: ""
        };

        _$state.params = {
            name: "Chai"
        };
        
        _NetworkSettingsService.connectedWifiNetwork = {
            state: {
                status: "connecting"
            },
            settings: {
                'wpa-ssid': "Chai" 
            }
        };

        _$scope.init();

        expect(_$scope.buttonValue).toEqual("CONNECTING");

    });

    it("It should test init method, when connectedNetwork in null", function() {

        /*_$scope.selectedWifiNow = {
            encryption: ""
        };

        _$state.params = {
            name: "Chai"
        };
        
        _NetworkSettingsService = {};

        _$scope.init();

        expect(_$scope.init).toThrowError();*/

    });


    it("It should test init method, when encryption is wpa2 psk", function() {

        _$scope.selectedWifiNow = {
            encryption: "wpa2 psk"
        };

        _$state.params = {
            name: "Chai"
        };
        
        _NetworkSettingsService.connectedWifiNetwork = {
            state: {
                status: "connecting"
            },
            settings: {
                'wpa-ssid': "Chai" 
            }
        };

        spyOn(_$scope, "updateConnectedWifi");

        _$scope.init();

        expect(_$scope.updateConnectedWifi).toHaveBeenCalledWith("wpa-ssid");
        expect(_$scope.wifiNetworkType).toEqual("wpa2 psk");
    });

    it("It should test init method, when encryption is wpa2 802.1x", function() {

        _$scope.selectedWifiNow = {
            encryption: "wpa2 802.1x"
        };

        _$state.params = {
            name: "Chai"
        };
        
        _NetworkSettingsService.connectedWifiNetwork = {
            state: {
                status: "connecting"
            },
            settings: {
                'wpa-ssid': "Chai" 
            }
        };

        spyOn(_$scope, "updateConnectedWifi");

        _$scope.init();

        expect(_$scope.updateConnectedWifi).toHaveBeenCalledWith("wpa-ssid");
        expect(_$scope.wifiNetworkType).toEqual("wpa2 802.1x");
    });

    it("It should test init method, when encryption is wep", function() {

        _$scope.selectedWifiNow = {
            encryption: "wep"
        };

        _$state.params = {
            name: "Chai"
        };
        
        _NetworkSettingsService.connectedWifiNetwork = {
            state: {
                status: "connecting"
            },
            settings: {
                'wpa-ssid': "Chai" 
            }
        };

        spyOn(_$scope, "updateConnectedWifi");

        _$scope.init();

        expect(_$scope.updateConnectedWifi).toHaveBeenCalledWith("wireless_essid");
        expect(_$scope.wifiNetworkType).toEqual("wep");
    });

    it("It should test init method, when encryption is none", function() {

        _$scope.selectedWifiNow = {
            encryption: "none"
        };

        _$state.params = {
            name: "Chai"
        };
        
        _NetworkSettingsService.connectedWifiNetwork = {
            state: {
                status: "connecting"
            },
            settings: {
                'wpa-ssid': "Chai" 
            }
        };

        spyOn(_$scope, "updateConnectedWifi");

        _$scope.init();

        expect(_$scope.updateConnectedWifi).toHaveBeenCalledWith("wireless_essid");
        expect(_$scope.wifiNetworkType).toEqual("none");
    });

    it("It should test ethernet connection", function() {

        _$scope.selectedWifiNow = null;
        
        _NetworkSettingsService.connectedEthernet = {
            interface: 'eth0',
            state: {
                status: "connected",
            },
            settings: {
                type: "static",
                gateway: '1:2:3:4',
                'dns-nameservers': "Chai Bio"
            }
        };

        _$scope.editEthernetData = {};

        _$state.params = {
            name: "ethernet"
        };

        _$scope.init();

        expect(_$scope.IamConnected).toEqual(true);
        expect(_$scope.autoSetting).toEqual("manual");
        expect(_$scope.editEthernetData.gateway).toEqual('1:2:3:4');
        expect(_$scope.editEthernetData['dns-nameservers']).toEqual("Chai");

    });

    it("It should test ethernet connection, ehrn settings have different values", function() {

        _$scope.selectedWifiNow = null;
        
        _NetworkSettingsService.connectedEthernet = {
            interface: 'eth0',
            state: {
                status: "connected",
            },
            settings: {
                type: "dynamic",
                gateway: null,
                'dns-nameservers': null
            }
        };

        _$scope.editEthernetData = {};

        _$state.params = {
            name: "ethernet"
        };

        _$scope.init();

        expect(_$scope.IamConnected).toEqual(true);
        expect(_$scope.autoSetting).toEqual("auto");
        expect(_$scope.editEthernetData.gateway).toEqual('0.0.0.0');
        expect(_$scope.editEthernetData['dns-nameservers']).toEqual("0.0.0.0");

    });

    it("It should test scenario, when ethernet or wifi not detected", function() {

         _$scope.selectedWifiNow = null;
        
        _NetworkSettingsService.connectedEthernet = {
            interface: null,
            state: {
                status: "connected",
            },
            settings: {
                type: "dynamic",
                gateway: null,
                'dns-nameservers': null
            }
        };

        _$timeout = function(callback, wait) {
            callback();
        };

        _$scope.init();

        //_$timeout.flush();
        expect(_$scope.selectedWifiNow).toEqual(null);
    }); 


});