(function() {
  'use strict'

  fdescribe("Testing PikaController", function() {

    beforeEach(module('ChaiBioTech', function($provide) {
      $provide.value('dynexpExperimentService', ExperimentServiceMock);
      $provide.value('Status', StatusServiceMock);
      $provide.value('NetworkSettingsService', NetworkSettingsServiceMock);
      $provide.value('dynexpDeviceInfo', DeviceInfoMock);
    }));

    beforeEach(inject(function(_$controller_, _$rootScope_, $httpBackend, $stateParams, $q) {
      this.$controller = _$controller_;
      this.$rootScope = _$rootScope_;
      this.$stateParams = $stateParams;
      this.httpMock = $httpBackend;

      this.$scope = this.$rootScope.$new();

      this.$stateParams.id = 10;
      //this.httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
      //$scope.experiment.id =10;

      this.PikaTestCtrl = this.$controller('PikaTestCtrl', { $scope: this.$scope });
      spyOn(this.$scope, 'checkExperimentStatus');
    }));

    it("should have PikaController", function() {
      expect(this.PikaTestCtrl).toBeDefined();
    });

    it("Positive control should be invalid", function() {
      this.$scope.getResults();
      //this.$scope.cq = [["channel","well_num","cq"],[1,1,"5"],[1,2,42.13],[1,3,40.89],[1,4,9.47],[1,5,20],[1,6,"26.33"],[1,7,"33.89"],[1,8,"5"],[1,9,"34.5"],[1,10,"19"],[1,11,"12"],[1,12,"6"],[1,13,"24"],[1,14,"39"],[1,15,"32"],[1,16,"18"],[2,1,"11"],[2,2,"25.15"],[2,3,36],[2,4,"8"],[2,5,"34"],[2,6,"10"],[2,7,"15"],[2,8,"25"],[2,9,"35"],[2,10,"28"],[2,11,"2"],[2,12,"7"],[2,13,"0"],[2,14,"35"],[2,15,"28"],[2,16,"17"]];

      expect(this.$scope.result[0]).toBe("Invalid");
    });

    it("Negative control should be invalid", function() {
      this.$scope.getResults();
      //this.$scope.cq = [["channel","well_num","cq"],[1,1,"5"],[1,2,42.13],[1,3,40.89],[1,4,9.47],[1,5,20],[1,6,"26.33"],[1,7,"33.89"],[1,8,"5"],[1,9,"34.5"],[1,10,"19"],[1,11,"12"],[1,12,"6"],[1,13,"24"],[1,14,"39"],[1,15,"32"],[1,16,"18"],[2,1,"11"],[2,2,"25.15"],[2,3,36],[2,4,"8"],[2,5,"34"],[2,6,"10"],[2,7,"15"],[2,8,"25"],[2,9,"35"],[2,10,"28"],[2,11,"2"],[2,12,"7"],[2,13,"0"],[2,14,"35"],[2,15,"28"],[2,16,"17"]];

      expect(this.$scope.result[1]).toBe("Invalid");
    });

    it("should call the broadcast listener", function() {
      var newData = {
        "experiment_controller": {
          "machine": {
            "state": "idle",
            "thermal_state": "idle"
          },
          "experiment": {
            "run_duration": "5",
            "id": "263",
            "name": "Lactobacillaceae Screening",
            "started_at": "2017-May-02 19:59:36.576900",
            "stage": {
              "id": "405",
              "name": "Stage 1",
              "number": "1",
              "cycle": "1"
            },
            "step": {
              "id": "680",
              "name": "Initial Denaturing",
              "number": "1"
            }
          }
        },
        "heat_block": {
          "zone1": {
            "temperature": "28.9580002",
            "target_temperature": "0",
            "drive": "-0"
          },
          "zone2": {
            "temperature": "29.0249996",
            "target_temperature": "0",
            "drive": "-0"
          },
          "temperature": "28.9909992"
        },
        "lid": {
          "temperature": "33.7010002",
          "target_temperature": "110",
          "drive": "1"
        },
        "optics": {
          "intensity": "60",
          "collect_data": "false",
          "lid_open": "false",
          "well_number": "0",
          "photodiode_value": [
            "1272",
            "1518"
          ]
        },
        "heat_sink": {
          "temperature": "29.1949997",
          "fan_drive": "0"
        },
        "device": {
          "update_available": "available"
        }
      };
      var oldData = {
        "experiment_controller": {
          "machine": {
            "state": "lid_heating",
            "thermal_state": "idle"
          },
          "experiment": {
            "run_duration": "5",
            "id": "263",
            "name": "Lactobacillaceae Screening",
            "started_at": "2017-May-02 19:59:36.576900",
            "stage": {
              "id": "405",
              "name": "Stage 1",
              "number": "1",
              "cycle": "1"
            },
            "step": {
              "id": "680",
              "name": "Initial Denaturing",
              "number": "1"
            }
          }
        },
        "heat_block": {
          "zone1": {
            "temperature": "28.9580002",
            "target_temperature": "0",
            "drive": "-0"
          },
          "zone2": {
            "temperature": "29.0249996",
            "target_temperature": "0",
            "drive": "-0"
          },
          "temperature": "28.9909992"
        },
        "lid": {
          "temperature": "33.7010002",
          "target_temperature": "110",
          "drive": "1"
        },
        "optics": {
          "intensity": "60",
          "collect_data": "false",
          "lid_open": "false",
          "well_number": "0",
          "photodiode_value": [
            "1272",
            "1518"
          ]
        },
        "heat_sink": {
          "temperature": "29.1949997",
          "fan_drive": "0"
        },
        "device": {
          "update_available": "available"
        }
      };

      this.$rootScope.$broadcast('status:data:updated', newData, oldData);
      //this.$scope.$apply();
      expect(this.$scope.checkExperimentStatus).toHaveBeenCalled();

    });

  });

})();
