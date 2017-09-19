describe("Testing NetworkSettingsService", function() {

   var _NetworkSettingsService, _$rootScope, _$http, _$q, _host, _$interval, _Webworker, $httpBackend, gg ;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

        });

        inject(function($injector) {
            $httpBackend = $injector.get('$httpBackend');
        
            $httpBackend.whenGET("http://localhost:8000/status").respond("NOTHING");
            $httpBackend.whenGET("http://localhost:8000/network/wlan").respond("NOTHING");
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

});