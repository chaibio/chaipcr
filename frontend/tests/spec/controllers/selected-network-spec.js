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

    it("It should test updateConnectedWifi method, when fifi has connection status", function() {

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
});