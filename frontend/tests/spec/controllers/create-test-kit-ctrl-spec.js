describe("Testing CreateTestKitCtrl", function() {

    var _Device, _$scope, _Status, _$http, _$window, _$timeout, _$location, _$state, _Testkit,
    _$rootScope, _$controller, _CreateTestKitCtrl;

    beforeEach(function() {
        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            __Device = $injector.get('Device');
            _$rootScope = $injector.get('$rootScope');

            _Status = $injector.get('Status');
            _$http = $injector.get('$http');
            _$window = $injector.get('$window');
            _$timeout = $injector.get('$timeout');
            _$location = $injector.get('$location');
            _$state = $injector.get('$state');
            _Testkit = $injector.get('Testkit');
            _$scope = _$rootScope.$new();
            _$controller = $injector.get('$controller');
            httpMock = $injector.get('$httpBackend');
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.expectPUT("http://localhost:8000/network/eth0").respond({
                status: {
                    
                }
            });
            _CreateTestKitCtrl = _$controller('CreateTestKitCtrl', {
                $scope: _$scope,
            });
            
        });
    });

    it("It should test initial values", function() {

        expect(_$scope.is_dual_channel).toEqual(false);
        expect(_$scope.update_available).toEqual("unavailable");
        expect(_$scope.exporting).toEqual(false);
        expect(_$scope.value).toEqual("Choose Manufacturer ..");
        expect(_$scope.selectedKit).toEqual(1);
        expect(_$scope.kit.name).toEqual('Lactobacillaceae Screening');
        expect(_$scope.kit1.name).toEqual('Lactobacillaceae Screening');
        expect(_$scope.kit2.name).toEqual('Lactobacillaceae Screening');
        expect(_$scope.creating).toEqual(false);
    });

    it("It should test create method when selectKit === 1", function() {

        _Testkit.create = function() {
            return {
                then: function(callback) {
                    var resp = {
                        data: {
                            experiment: {
                                id: 10
                            }
                        }
                    };
                    callback(resp);
                }
            };
        };

        _Testkit.createWells = function() {
            return {
                then: function(callback) {
                    callback();
                    return {
                        catch: function(callback) {
                            var response = {
                                data: {
                                    errors: "Error cought"
                                }
                            };
                            callback(response);
                        }
                    };
                },
                catch: function(callback) {
                    var response = {
                        data: {
                            errors: "Error cought"
                        }
                    };
                    callback(response);
                }
                
            };
        };

        _$state.go = function() {

        };
        _$scope.$close = function() {

        };

        spyOn(_Testkit, "create").and.callThrough();
        spyOn(_Testkit, "createWells").and.callThrough();
        spyOn(_$state, "go").and.callThrough();
        spyOn(_$scope, "$close").and.callThrough();

        _$scope.create();

        expect(_Testkit.create).toHaveBeenCalled();
        expect(_Testkit.createWells).toHaveBeenCalled();
        expect(_$state.go).toHaveBeenCalled();
        expect(_$scope.$close).toHaveBeenCalled();
    });

    it("It should test create method when selectKit === 2", function() {

        _Testkit.create = function() {
            return {
                then: function(callback) {
                    var resp = {
                        data: {
                            experiment: {
                                id: 10
                            }
                        }
                    };
                    callback(resp);
                }
            };
        };

        _Testkit.createWells = function() {
            return {
                then: function(callback) {
                    callback();
                    return {
                        catch: function(callback) {
                            var response = {
                                data: {
                                    errors: "Error cought"
                                }
                            };
                            callback(response);
                        }
                    };
                },
                catch: function(callback) {
                    var response = {
                        data: {
                            errors: "Error cought"
                        }
                    };
                    callback(response);
                }
                
            };
        };

        _$state.go = function() {

        };
        _$scope.$close = function() {

        };
        

        spyOn(_Testkit, "create").and.callThrough();
        spyOn(_Testkit, "createWells").and.callThrough();
        spyOn(_$state, "go").and.callThrough();
        spyOn(_$scope, "$close").and.callThrough();
        
        _$scope.selectedKit = 2;
        _$scope.kit2 = {
            name: "kit"
        };

        _$scope.$digest();

        _$scope.create();

        expect(_Testkit.create).toHaveBeenCalled();
        expect(_Testkit.createWells).toHaveBeenCalled();
        expect(_$state.go).toHaveBeenCalled();
        expect(_$scope.$close).toHaveBeenCalled();
    });

    it("It should test window.onclick event", function() {

        angular.element(_$window).click();
        //_$window.click();

        //expect(1).toEqual(2);
    });

});