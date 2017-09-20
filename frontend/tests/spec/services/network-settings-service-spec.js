describe("Testing NetworkSettingsService", function() {

   var _NetworkSettingsService, _$rootScope, _$http, _$q, _host, _$interval, _Webworker, $httpBackend, gg ;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

        });

        inject(function($injector) {
            $httpBackend = $injector.get('$httpBackend');
        
            $httpBackend.whenGET("http://localhost:8000/status").respond("NOTHING");
            $httpBackend.whenGET("http://localhost:8000/network/wlan").respond({
            data: {
                state: {
                    macAddress: "125",
                    status: {

                    }
                }
            }
        });
            //$httpBackend.expectPOST("http://localhost:8000/control/start").respond({});

            _$rootScope = $injector.get('$rootScope');
            _$http = $injector.get('$http');
            _$q = $injector.get('$q');
            _host = $injector.get('host');
            _$interval = $injector.get('$interval');
            _NetworkSettingsService = $injector.get('NetworkSettingsService');
            
            
            
        });
        
        afterEach(function() {
            //$httpBackend.verifyNoOutstandingExpectation();
            //$httpBackend.verifyNoOutstandingRequest();
        });
    }); 

    it("It should test getWifiNetworks method", function() {

        spyOn(_$http, "get").and.callThrough();
        $httpBackend.expectGET( _host + ':8000/network/wlan/scan').respond({
                        
                            scan_result: [
                                {ssid: 1},
                                {ssid: 2}
                            ]
                        
                    });
        _NetworkSettingsService.getWifiNetworks();
        $httpBackend.flush();
        expect(_NetworkSettingsService.listofAllWifi[1].ssid).toEqual(1);
        expect(_$http.get).toHaveBeenCalled();
    });

    it("It should test getSettings method", function() {

        spyOn(_NetworkSettingsService, "accessLanLookup").and.returnValue(true);
        _NetworkSettingsService.getSettings();
        expect(_NetworkSettingsService.accessLanLookup).toHaveBeenCalled();
        expect(_NetworkSettingsService.intervalKey).not.toEqual(null);
    });

    it("It should test accessLanLookup method", function() {

        _NetworkSettingsService.userSettings.wifiSwitchOn = true;
        spyOn(_NetworkSettingsService, "lanLookup").and.returnValue(true);
        _NetworkSettingsService.accessLanLookup();
        expect(_NetworkSettingsService.lanLookup).toHaveBeenCalled();

    });

    it("It should test lanLookup method", function() {

        spyOn(_NetworkSettingsService, "processData").and.returnValue(true);
        _NetworkSettingsService.lanLookup();
        $httpBackend.flush();
        expect(_NetworkSettingsService.processData).toHaveBeenCalled();
    });

    it("It should test lanLookup method when request fails", function() {

        spyOn(_NetworkSettingsService, "processOnError").and.returnValue(true);
        $httpBackend.expectGET(_host + ':8000/network/wlan').respond(503, '');
        _NetworkSettingsService.lanLookup();
        $httpBackend.flush();
        expect(_NetworkSettingsService.processOnError).toHaveBeenCalled();
    });

    it("It should test processData method", function() {
        
        _NetworkSettingsService.wirelessError = true;
        var wlanOutput = {
            data: {
                state: {
                    macAddress: '123'
                },
                settings: {
                    on: true,
                }
            }
        };
        
        spyOn(_$rootScope, "$broadcast");
        _NetworkSettingsService.processData(wlanOutput);

        expect(_$rootScope.$broadcast).toHaveBeenCalled();
    });

    it("It should test processData method, and check for macAddress", function() {

        var wlanOutput = {
            data: {
                state: {
                    macAddress: '123'
                },
                settings: {
                    on: true,
                }
            }
        };

        _NetworkSettingsService.processData(wlanOutput);
        expect(_NetworkSettingsService.macAddress).toEqual('123');

    });

    it("It should test processData method, when new wifi data is available", function() {

        var wlanOutput = {
            data: {
                state: {
                    macAddress: '123'
                },
                settings: {
                    on: true,
                }
            }
        };
        spyOn(_$rootScope, "$broadcast");
        _NetworkSettingsService.processData(wlanOutput);
        expect(_$rootScope.$broadcast).toHaveBeenCalledWith('new_wifi_result');
    });

    it("It should test processOnError method, which is executed when wifi not able to connect", function() {

        var err = {
            data: {
                status: "not connected"
            },
        };

        spyOn(_$rootScope, "$broadcast");
        _NetworkSettingsService.processOnError(err);
        expect(_$rootScope.$broadcast).toHaveBeenCalledWith('wifi_adapter_error');
        expect(_NetworkSettingsService.wirelessErrorData).toEqual("not connected");
    });

    it("It should test getReady method", function() {

        $httpBackend.expectGET(_host + ':8000/network/wlan').respond({
             
                state: {
                    macAddress: "125",
                    status: {

                    }
                }
            
        });

        _NetworkSettingsService.getReady();
        $httpBackend.flush();

        expect(_NetworkSettingsService.macAddress).toEqual("125");
    });

    it("It should test getReady method, when server returns error", function() {

        $httpBackend.expectGET(_host + ':8000/network/wlan').respond(502, '');

        spyOn(_NetworkSettingsService, "processOnError").and.returnValue(true);
        _NetworkSettingsService.getReady();
        $httpBackend.flush();

        expect(_NetworkSettingsService.processOnError).toHaveBeenCalled();
    });

    it("It should test getEthernetStatus method", function() {

        $httpBackend.expectGET(_host + ':8000/network/eth0').respond({
            state: {
                address: "110:0:0:1",
            }
        });
        
        _NetworkSettingsService.getEthernetStatus();
        $httpBackend.flush();
        expect(_NetworkSettingsService.connectedEthernet.state.address).toEqual("110:0:0:1");
    });

    it("It should test connectWifi method", function() {

        $httpBackend.expectPUT(_host + ':8000/network/wlan').respond({
            status: {
                connected: true
            }
        });

        _NetworkSettingsService.connectWifi();
        $httpBackend.flush();

    });

    it("It should test connectWifi method, when returned error", function() {

        $httpBackend.expectPUT(_host + ':8000/network/wlan').respond(502);

        _NetworkSettingsService.connectWifi();
        $httpBackend.flush();

    });

    it("It should test connectToEthernet method", function() {

        var ethernetParams = {
            type: null
        };

        $httpBackend.expectPUT(_host + ':8000/network/eth0').respond({
            status: {
                connected: true
            }
        });
        
        _NetworkSettingsService.connectToEthernet(ethernetParams);
        $httpBackend.flush();
        expect(ethernetParams.type).toEqual('static');
    });

    it("It should test connectToEthernet method, when connection refused", function() {

        var ethernetParams = {
            type: null
        };

        $httpBackend.expectPUT(_host + ':8000/network/eth0').respond(502);
        
        _NetworkSettingsService.connectToEthernet(ethernetParams);
        $httpBackend.flush();
        expect(ethernetParams.type).toEqual('static');
    });

    it("It should test changeToAutomatic method", function() {

        var ethernetParams = {
            type: null
        };

        $httpBackend.expectPUT(_host + ':8000/network/eth0').respond({
            status: {
                connected: true
            }
        });

        _NetworkSettingsService.changeToAutomatic(ethernetParams);
        $httpBackend.flush();
        expect(ethernetParams.type).toEqual('dhcp');

    });

    it("It should test changeToAutomatic method, when connection rejected", function() {

        var ethernetParams = {
            type: null
        };

        $httpBackend.expectPUT(_host + ':8000/network/eth0').respond(502);

        _NetworkSettingsService.changeToAutomatic(ethernetParams);
        $httpBackend.flush();
        expect(ethernetParams.type).toEqual('dhcp');

    });

    it("It should test stop method", function() {
        
        $httpBackend.expectPOST(_host + ':8000/network/wlan/disconnect').respond({
            status: "okay"
        });
        
        _NetworkSettingsService.stop();
        $httpBackend.flush();
        expect(_NetworkSettingsService.userSettings.wifiSwitchOn).toEqual(false);
    });

    it("It should test stop method, when connection rejected", function() {
        
        $httpBackend.expectPOST(_host + ':8000/network/wlan/disconnect').respond(502);
        
        _NetworkSettingsService.stop();
        $httpBackend.flush();
        expect(_NetworkSettingsService.userSettings.wifiSwitchOn).toEqual(false);
    });

    it("It should test restart method", function() {

        $httpBackend.expectPOST(_host + ':8000/network/wlan/connect').respond({
            restart: "okay"
        });

        
    });
});