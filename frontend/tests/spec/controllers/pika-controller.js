(function() {
  'use strict'

  describe("Testing PikaController", function() {

    beforeEach(module('ChaiBioTech', function($provide) {
      $provide.value('IsTouchScreen', function () {});
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
      expect(this.$scope.result[0]).toBe("Invalid");
    });

    it("Positive control amount should be repeat", function() {
      this.$scope.getResults();
      expect(this.$scope.amount[0]).toBe("Repeat");
    });

    it("Negative control should be Valid", function() {
      this.$scope.getResults();
      expect(this.$scope.result[1]).toBe("Valid");
    });

    it("Negative control amount should be -", function() {
      this.$scope.getResults();
      expect(this.$scope.amount[1]).toBe("\u2014");
    });

    it("Sample Result should be Unknown", function() {
      this.$scope.getResults();
      expect(this.$scope.result[2]).toBe("Unknown");
    });

    it("Sample Result should be Invalid", function() {
      this.$scope.getResults();
      expect(this.$scope.result[3]).toBe("Invalid");
    });

    it("Sample Result should be Inhibited", function() {
      this.$scope.getResults();
      expect(this.$scope.result[4]).toBe("Inhibited");
    });

    it("Sample Result should be Positive", function() {
      this.$scope.getResults();
      expect(this.$scope.result[5]).toBe("Positive");
    });

    it("Sample Amount should be Repeat PCR", function() {
      this.$scope.getResults();
      expect(this.$scope.amount[2]).toBe("Repeat PCR");
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
