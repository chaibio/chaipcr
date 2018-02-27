describe("Testing systemController", function() {

   var _Device, _$scope, _Status, _$http, _$window, _$timeout, systemController, _$rootScope;

   beforeEach(function() {
        
        module('ChaiBioTech', function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            _Device = $injector.get('Device');
            _Status = $injector.get('Status');
            _$http = $injector.get('$http');
            _$window = $injector.get('$window');
            _$controller = $injector.get('$controller');

            systemController = _$controller('systemController', {
                $scope: _$scope
            });
        });
        
   });

   it("It should test initial values", function() {

      expect(_$scope.is_dual_channel).toEqual(false); 
      expect(_$scope.update_available).toEqual('unavailable');
      expect(_$scope.exporting).toEqual(false);
   });

   it("It should test getVersionSoft method", function() {

        _Device.getVersion = function() {
            return {
                then: function(callback) {
                    var data = {
                        version: "2.0"
                    };
                    callback(data);
                }
            };
        };

        spyOn(_Device, "getVersion").and.callThrough();

        _$scope.getVersionSoft();

        expect(_Device.getVersion).toHaveBeenCalled();
        expect(_$scope.data.version).toEqual("2.0");
   });

   it("It should test getVersionSoft method, when error callback works", function() {

        _Device.getVersion = function() {
            return {
                then: function(callback, error) {
                    var data = {
                        version: "2.0"
                    };
                    error(data);
                }
            };
        };

        spyOn(_Device, "getVersion").and.callThrough();

        _$scope.getVersionSoft();

        expect(_Device.getVersion).toHaveBeenCalled();
        expect(_$scope.data.software.version).toEqual("1.0.0");
   });

   it("It should test 'status:data:updated' event", function() {

        var data = {
            device: {
                update_available: 'available'
            },
        };

        _$scope.$broadcast('status:data:updated', data);

        expect(_$scope.update_available).toEqual('available');
   });

   it("It should test openUpdateModal method", function() {

        _Device.openUploadModal = function() {};

        spyOn(_Device, "openUploadModal");

        _$scope.openUploadModal();

        expect(_Device.openUploadModal).toHaveBeenCalled();
   });

   
});