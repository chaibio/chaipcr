describe("It should test amplificationChart", function() {

  var _$scope, _Experiment, _AmplificationChartCtrl, _$rootScope, _$stateParams, _helper, 
  _expName, _$interval, _Device, _$timeout, _focus;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
    
            _$rootScope = $injector.get('$rootScope');        
            _$scope = _$rootScope.$new();
            _$controller = $injector.get('$controller');
            _Experiment = $injector.get('Experiment');
            
            _$stateParams = $injector.get('$stateParams');
            _helper = $injector.get('AmplificationChartHelper');
            _expName = $injector.get('expName');
            _$interval = $injector.get('$interval');
            _Device = $injector.get('Device');
            _$timeout = $injector.get('$timeout');
            _focus = $injector.get('focus');

            httpMock = $injector.get('$httpBackend');

            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.expectPUT("http://localhost:8000/network/eth0").respond({
                status: {
                    
                }
            });
            
            _Device.isDualChannel = function() {
              var is_dual_channel = true;
              return {
                then: function(callback) {
                  callback(is_dual_channel);
                }
              };
            };

            _AmplificationChartCtrl = _$controller('AmplificationChartCtrl', {
                $scope: _$scope,
            });
            
        });
    });

    it("It should test initial values", function() {

      spyOn(_helper, "chartConfig").and.returnValue({
          channels: 10,
          axes: {
            x: {
              max: 10
            }
          },

      });

      spyOn(_helper, "paddData").and.returnValue({

      });

      expect(_$scope.chartConfig).toEqual(jasmine.any(Object));
      expect(_$scope.is_dual_channel).toEqual(true);
      expect(_$scope.chartConfig.channels).toEqual(2);
      expect(_$scope.chartConfig.axes.x.max).toEqual(1);
      expect(_$scope.amplification_data).toEqual(jasmine.any(Object));
      expect(_$scope.baseline_subtraction).toEqual(true);
      expect(_$scope.curve_type).toEqual('linear');
      expect(_$scope.color_by).toEqual('well');
      expect(_$scope.retrying).toEqual(false);
      expect(_$scope.retry).toEqual(0);
      expect(_$scope.fetching).toEqual(false);
      expect(_$scope.channel_1).toEqual(true);
      expect(_$scope.channel_2).toEqual(true);
      expect(_$scope.ampli_zoom).toEqual(0);
      expect(_$scope.showOptions).toEqual(true);
      expect(_$scope.isError).toEqual(false);
      expect(_$scope.method.name).toEqual('Cy0');
    });

});
