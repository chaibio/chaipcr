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
            httpMock.expectGET("/experiments/undefined/amplification_option").respond("NOTHING");
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
      expect(_$scope.cy0.name).toEqual('Cy0');
      expect(_$scope.cy0.desciption).toEqual('A Cq calling method based on the max first derivative of the curve (recommended).');
      expect(_$scope.cpd2.name).toEqual('cpD2');
      expect(_$scope.cpd2.desciption).toEqual('A Cq calling method based on the max second derivative of the curve.');

      expect(_$scope.cpd2.name).toEqual('cpD2');
      expect(_$scope.cpd2.desciption).toEqual('A Cq calling method based on the max second derivative of the curve.');

      expect(_$scope.minFl.name).toEqual('Min Fluoresence');
      expect(_$scope.minFl.desciption).toEqual('The minimum fluorescence threshold for Cq calling. Cq values will not be called when the fluorescence is below this threshold.');
      expect(_$scope.minFl.value).toEqual(null);

      expect(_$scope.minCq.name).toEqual('Min Cycle');
      expect(_$scope.minCq.desciption).toEqual('The earliest cycle to use in Cq calling & baseline subtraction. Data for earlier cycles will be ignored.');
      expect(_$scope.minCq.value).toEqual(null);

      expect(_$scope.minDf.name).toEqual('Min 1st Derivative');
      expect(_$scope.minDf.desciption).toEqual('The threshold which the first derivative of the curve must exceed for a Cq to be called.');
      expect(_$scope.minDf.value).toEqual(null);

      expect(_$scope.minD2f.name).toEqual('Min 2nd Derivative');
      expect(_$scope.minD2f.desciption).toEqual('The threshold which the second derivative of the curve must exceed for a Cq to be called.');
      expect(_$scope.minD2f.value).toEqual(null);

      expect(_$scope.baseline_sub).toEqual('auto');

      expect(_$scope.baseline_auto.name).toEqual('Auto');
      expect(_$scope.baseline_auto.desciption).toEqual('Automatically detect the baseline cycles.');

      expect(_$scope.baseline_manual.name).toEqual('Manual');
      expect(_$scope.baseline_manual.desciption).toEqual('Manually specify the baseline cycles.');

      expect(_$scope.cyclesFrom).toEqual(null);
      expect(_$scope.cyclesTo).toEqual(null);
      expect(_$scope.hoverName).toEqual("Min. Fluoresence");
      expect(_$scope.hoverDescription).toEqual("This is a test description");
      expect(_$scope.samples).toEqual(jasmine.any(Array));
      expect(_$scope.editExpNameMode).toEqual(jasmine.any(Array));
    });

    it("It should test expName:Updated change", function() {

      _expName.name = "chai1";
      
      
      _$scope.experiment = {
        name: "something",
        id: 10,
      };

      //_$scope.$digest();
      _$scope.$broadcast('expName:Updated');
      console.log(_expName);
      
      expect(_$scope.experiment.name).toEqual(_expName.name);
    });

    it("It should test check method", function() {

      _$scope.check();
      expect(_$scope.errorCheck).toEqual(true);
      expect(_$scope.hoverName).toEqual("Error");
      //expect(_$scope.hoverDescription).toEqual('Min Fluurescence cannot be left empty');
      expect(_$scope.hoverOn).toEqual(true);
      expect(_$scope.errorCheck).toEqual(true);
      expect(_$scope.errorFl).toEqual(true);

    });

});
