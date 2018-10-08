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

    describe('PikaTest One TestKit Result', function() {
      describe('Positive Control Result', function() {
        it('Rule 1: (20 <= FAM Cq <= 34 | HEX Cq = Any) -> `Valid` ', function() {          
          this.$scope.famCq[0] = 19;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[0]).toEqual('Invalid');

          this.$scope.famCq[0] = 25;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[0]).toEqual('Valid');

          this.$scope.famCq[0] = 35;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[0]).toEqual('Invalid');
        });

        it('Rule 2: All Other Cases -> `Invalid` ', function() {          
          this.$scope.famCq[0] = 19;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[0]).toEqual('Invalid');

          this.$scope.famCq[0] = 35;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[0]).toEqual('Invalid');
        });

      });

      describe('Negative Control Result', function() {
        it('Rule 1: ( FAM Cq is Blank | 20 <= HEX Cq <= 36) -> `Valid` ', function() {          
          this.$scope.famCq[1] = null;
          this.$scope.hexCq[1] = 25;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');

          this.$scope.famCq[1] = null;
          this.$scope.hexCq[1] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');

          this.$scope.famCq[1] = null;
          this.$scope.hexCq[1] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');
        });

        it('Rule 2: ( 38 < FAM Cq <= 40 | 20 <= HEX Cq <= 36) -> `Valid` ', function() {          
          this.$scope.famCq[1] = 39;
          this.$scope.hexCq[1] = 25;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');

          this.$scope.famCq[1] = 39;
          this.$scope.hexCq[1] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');

          this.$scope.famCq[1] = 39;
          this.$scope.hexCq[1] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');

          ////////////////////////////////////////////////
          this.$scope.famCq[1] = 40;
          this.$scope.hexCq[1] = 25;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');

          this.$scope.famCq[1] = 40;
          this.$scope.hexCq[1] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');

          this.$scope.famCq[1] = 40;
          this.$scope.hexCq[1] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Valid');

        });

        it('Rule 3: All Other Cases -> `Invalid` ', function() {          
          this.$scope.famCq[1] = null;
          this.$scope.hexCq[1] = 19;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Invalid');

          this.$scope.famCq[1] = null;
          this.$scope.hexCq[1] = 37;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Invalid');

          ////////////////////////////////////////////////

          this.$scope.famCq[1] = 38;
          this.$scope.hexCq[1] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Invalid');

          this.$scope.famCq[1] = 41;
          this.$scope.hexCq[1] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Invalid');

          ////////////////////////////////////////////////

          this.$scope.famCq[1] = 38;
          this.$scope.hexCq[1] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Invalid');

          this.$scope.famCq[1] = 41;
          this.$scope.hexCq[1] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[1]).toEqual('Invalid');

          ////////////////////////////////////////////////
        });
      });

      describe('Sample Result', function() {
        it('Rule 1: (Positive: Any | Negative: Invalid | FAM Cq: Any | HEX Cq: Any) -> `Invalid` ', function() {          
          //Positive: Invalid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
          this.$scope.famCq = [0, 0, 0];
          this.$scope.hexCq = [0, 0, 0];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Invalid');

          //Positive: Valid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
          this.$scope.famCq = [20, 36, 10];
          this.$scope.hexCq = [10, 38, 10];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Invalid');
        });

        it('Rule 2: (Positive: Valid | Negative: Valid | 10 <= FAM Cq <= 38 | HEX Cq: Any) -> `Positive` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any
          this.$scope.famCq = [20, 39, 10];
          this.$scope.hexCq = [10, 20, 10];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Positive');

          //Positive: Valid | Negative: Valid | FAM Cq: 38 | HEX Cq: Any
          this.$scope.famCq = [20, 39, 38];
          this.$scope.hexCq = [10, 20, 10];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Positive');

          //Positive: Valid | Negative: Valid | FAM Cq: 20 | HEX Cq: Any
          this.$scope.famCq = [20, 39, 20];
          this.$scope.hexCq = [10, 20, 10];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Positive');
        });

        it('Rule 3: (Positive: Valid | Negative: Valid | FAM Cq: No Cq | 20 <= HEX Cq <=36) -> `Negative` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 20
          this.$scope.famCq = [20, 39, null];
          this.$scope.hexCq = [10, 20, 20];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Negative');

          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 36
          this.$scope.famCq = [20, 39, null];
          this.$scope.hexCq = [10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Negative');

          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 30
          this.$scope.famCq = [20, 39, null];
          this.$scope.hexCq = [10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Negative');
        });

        it('Rule 4: (Positive: Valid | Negative: Valid | FAM Cq > 38 | 20 <= HEX Cq <=36) -> `Negative` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 20
          this.$scope.famCq = [20, 39, 39];
          this.$scope.hexCq = [10, 20, 20];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Negative');

          //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 36
          this.$scope.famCq = [20, 39, 39];
          this.$scope.hexCq = [10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Negative');

          //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 30
          this.$scope.famCq = [20, 39, 39];
          this.$scope.hexCq = [10, 20, 30];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Negative');
        });

        it('Rule 5: (Positive: Any | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq) -> `Inhibited` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq
          this.$scope.famCq = [20, 39, null];
          this.$scope.hexCq = [10, 20, null];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Inhibited');

          //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq
          this.$scope.famCq = [10, 39, null];
          this.$scope.hexCq = [10, 20, null];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Inhibited');
        });

        it('Rule 6: (Positive: Any | Negative: Valid | FAM Cq: No Cq | HEX Cq > 36) -> `Inhibited` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 37
          this.$scope.famCq = [20, 39, null];
          this.$scope.hexCq = [10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Inhibited');

          //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 37
          this.$scope.famCq = [10, 39, null];
          this.$scope.hexCq = [10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Inhibited');
        });

        it('Rule 7: (Positive: Any | Negative: Valid | FAM Cq: > 38 | HEX Cq: No Cq) -> `Inhibited` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: No Cq
          this.$scope.famCq = [20, 39, 39];
          this.$scope.hexCq = [10, 20, null];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Inhibited');

          //Positive: Invalid | Negative: Valid | FAM Cq: 39 | HEX Cq: No Cq
          this.$scope.famCq = [10, 39, 39];
          this.$scope.hexCq = [10, 20, null];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Inhibited');
        });

        it('Rule 8: (Positive: Any | Negative: Valid | FAM Cq: > 38 | HEX Cq > 36) -> `Inhibited` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
          this.$scope.famCq = [20, 39, 39];
          this.$scope.hexCq = [10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Inhibited');

          //Positive: Invalid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
          this.$scope.famCq = [10, 39, 39];
          this.$scope.hexCq = [10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Inhibited');
        });

        it('Rule 9: All Other Cases -> `Invalid` ', function() {          
          //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 36
          this.$scope.famCq = [10, 39, null];
          this.$scope.hexCq = [10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Invalid');

          //Positive: Valid | Negative: Valid | FAM Cq: 9 | HEX Cq: 36
          this.$scope.famCq = [20, 39, 9];
          this.$scope.hexCq = [10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Invalid');

          //Positive: Invalid | Negative: Valid | FAM Cq: 38 | HEX Cq: No Cq
          this.$scope.famCq = [10, 39, 38];
          this.$scope.hexCq = [10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[2]).toEqual('Invalid');
        });
      });

      describe('Concentration Amount', function() {
        it('Rule 1: (Result: Positive | FAM Cq: < 10) -> `N/A` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [20, 39, 10];
          this.$scope.hexCq = [10, 20, 10];
        });

        it('Rule 2: (Result: Positive | 10 <= FAM Cq: <= 24) -> `High` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [20, 39, 10];
          this.$scope.hexCq = [10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('High');

          //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
          this.$scope.famCq = [20, 39, 24];
          this.$scope.hexCq = [10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('High');

        });

        it('Rule 3: (Result: Positive | 24 < FAM Cq: <= 30) -> `Medium` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [20, 39, 25];
          this.$scope.hexCq = [10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('Medium');

          //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
          this.$scope.famCq = [20, 39, 30];
          this.$scope.hexCq = [10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('Medium');

        });

        it('Rule 4: (Result: Positive | 30 < FAM Cq: <= 38) -> `Low` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [20, 39, 31];
          this.$scope.hexCq = [10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('Low');

          //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
          this.$scope.famCq = [20, 39, 38];
          this.$scope.hexCq = [10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('Low');

        });

        it('Rule 5: (Result: Positive | FAM Cq: > 38) -> `N/A` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [20, 39, 31];
          this.$scope.hexCq = [10, 20, 10];

        });

        it('Rule 6: (Result: Negative | FAM Cq: Any) -> `Not Detectable` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 20
          this.$scope.famCq = [20, 39, null];
          this.$scope.hexCq = [10, 20, 20];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('Not Detectable');

          //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 20
          this.$scope.famCq = [20, 39, 39];
          this.$scope.hexCq = [10, 20, 20];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('Not Detectable');

        });

        it('Rule 7: (Result: Inhibited | FAM Cq: Any) -> `Repeat` ', function() {          
          //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
          this.$scope.famCq = [20, 39, 39];
          this.$scope.hexCq = [10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('Repeat');

        });

        it('Rule 8: (Result: Invalid | FAM Cq: Any) -> `Repeat` ', function() {          
          //Positive: Invalid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
          this.$scope.famCq = [0, 0, 0];
          this.$scope.hexCq = [0, 0, 0];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[2]).toEqual('Repeat');

        });

        it('Rule 9: (Result: Valid | FAM Cq: Any) -> `(Blank)` ', function() {          
        });

      });
    });

    describe('PikaTest Two TestKit Result', function(){

      describe('Positive Control Result', function() {
        it('Rule 1: (20 <= FAM Cq <= 34 | HEX Cq = Any) -> `Valid` ', function() {
          this.$scope.twoKits = true;      

          this.$scope.famCq[8] = 19;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[8]).toEqual('Invalid');

          this.$scope.famCq[8] = 25;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[8]).toEqual('Valid');

          this.$scope.famCq[8] = 35;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[8]).toEqual('Invalid');
        });

        it('Rule 2: All Other Cases -> `Invalid` ', function() {
          this.$scope.twoKits = true;

          this.$scope.famCq[8] = 19;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[8]).toEqual('Invalid');

          this.$scope.famCq[8] = 35;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[8]).toEqual('Invalid');
        });

      });

      describe('Negative Control Result', function() {
        it('Rule 1: ( FAM Cq is Blank | 20 <= HEX Cq <= 36) -> `Valid` ', function() {
          this.$scope.twoKits = true;

          this.$scope.famCq[9] = null;
          this.$scope.hexCq[9] = 25;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');

          this.$scope.famCq[9] = null;
          this.$scope.hexCq[9] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');

          this.$scope.famCq[9] = null;
          this.$scope.hexCq[9] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');
        });

        it('Rule 2: ( 38 < FAM Cq <= 40 | 20 <= HEX Cq <= 36) -> `Valid` ', function() {
          this.$scope.twoKits = true;

          this.$scope.famCq[9] = 39;
          this.$scope.hexCq[9] = 25;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');

          this.$scope.famCq[9] = 39;
          this.$scope.hexCq[9] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');

          this.$scope.famCq[9] = 39;
          this.$scope.hexCq[9] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');

          ////////////////////////////////////////////////
          this.$scope.famCq[9] = 40;
          this.$scope.hexCq[9] = 25;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');

          this.$scope.famCq[9] = 40;
          this.$scope.hexCq[9] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');

          this.$scope.famCq[9] = 40;
          this.$scope.hexCq[9] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Valid');

        });

        it('Rule 3: All Other Cases -> `Invalid` ', function() {
          this.$scope.twoKits = true;

          this.$scope.famCq[9] = null;
          this.$scope.hexCq[9] = 19;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Invalid');

          this.$scope.famCq[9] = null;
          this.$scope.hexCq[9] = 37;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Invalid');

          ////////////////////////////////////////////////

          this.$scope.famCq[9] = 38;
          this.$scope.hexCq[9] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Invalid');

          this.$scope.famCq[9] = 41;
          this.$scope.hexCq[9] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Invalid');

          ////////////////////////////////////////////////

          this.$scope.famCq[9] = 38;
          this.$scope.hexCq[9] = 36;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Invalid');

          this.$scope.famCq[9] = 41;
          this.$scope.hexCq[9] = 20;
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[9]).toEqual('Invalid');

          ////////////////////////////////////////////////
        });
      });

      describe('Sample Result', function() {
        it('Rule 1: (Positive: Any | Negative: Invalid | FAM Cq: Any | HEX Cq: Any) -> `Invalid` ', function() {
          this.$scope.twoKits = true;

          //Positive: Invalid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Invalid');

          //Positive: Valid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 36, 10];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 38, 10];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Invalid');
        });

        it('Rule 2: (Positive: Valid | Negative: Valid | 10 <= FAM Cq <= 38 | HEX Cq: Any) -> `Positive` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 10];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Positive');

          //Positive: Valid | Negative: Valid | FAM Cq: 38 | HEX Cq: Any
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 38];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Positive');

          //Positive: Valid | Negative: Valid | FAM Cq: 20 | HEX Cq: Any
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 20];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Positive');
        });

        it('Rule 3: (Positive: Valid | Negative: Valid | FAM Cq: No Cq | 20 <= HEX Cq <=36) -> `Negative` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 20
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 20];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Negative');

          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 36
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Negative');

          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 30
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Negative');
        });

        it('Rule 4: (Positive: Valid | Negative: Valid | FAM Cq > 38 | 20 <= HEX Cq <=36) -> `Negative` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 20
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 20];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Negative');

          //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 36
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Negative');

          //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 30
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Negative');
        });

        it('Rule 5: (Positive: Any | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq) -> `Inhibited` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, null];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Inhibited');

          //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, null];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Inhibited');
        });

        it('Rule 6: (Positive: Any | Negative: Valid | FAM Cq: No Cq | HEX Cq > 36) -> `Inhibited` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 37
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Inhibited');

          //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 37
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Inhibited');
        });

        it('Rule 7: (Positive: Any | Negative: Valid | FAM Cq: > 38 | HEX Cq: No Cq) -> `Inhibited` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: No Cq
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, null];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Inhibited');

          //Positive: Invalid | Negative: Valid | FAM Cq: 39 | HEX Cq: No Cq
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, null];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Inhibited');
        });

        it('Rule 8: (Positive: Any | Negative: Valid | FAM Cq: > 38 | HEX Cq > 36) -> `Inhibited` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Inhibited');

          //Positive: Invalid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Inhibited');
        });

        it('Rule 9: All Other Cases -> `Invalid` ', function() {
          this.$scope.twoKits = true;

          //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 36
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Invalid');

          //Positive: Valid | Negative: Valid | FAM Cq: 9 | HEX Cq: 36
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 9];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Invalid');

          //Positive: Invalid | Negative: Valid | FAM Cq: 38 | HEX Cq: No Cq
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, 38];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.result[10]).toEqual('Invalid');
        });
      });

      describe('Concentration Amount', function() {
        it('Rule 1: (Result: Positive | FAM Cq: < 10) -> `N/A` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 10];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];
        });

        it('Rule 2: (Result: Positive | 10 <= FAM Cq: <= 24) -> `High` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 10];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('High');

          //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 24];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('High');

        });

        it('Rule 3: (Result: Positive | 24 < FAM Cq: <= 30) -> `Medium` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 25];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('Medium');

          //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 30];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('Medium');

        });

        it('Rule 4: (Result: Positive | 30 < FAM Cq: <= 38) -> `Low` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 31];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('Low');

          //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 38];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('Low');

        });

        it('Rule 5: (Result: Positive | FAM Cq: > 38) -> `N/A` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 31];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

        });

        it('Rule 6: (Result: Negative | FAM Cq: Any) -> `Not Detectable` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 20
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 20];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('Not Detectable');

          //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 20
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 20];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('Not Detectable');

        });

        it('Rule 7: (Result: Inhibited | FAM Cq: Any) -> `Repeat` ', function() {
          this.$scope.twoKits = true;

          //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('Repeat');

        });

        it('Rule 8: (Result: Invalid | FAM Cq: Any) -> `Repeat` ', function() {
          this.$scope.twoKits = true;

          //Positive: Invalid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
          this.$scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          this.$scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
          this.PikaTestCtrl.getResultArray();
          expect(this.$scope.amount[10]).toEqual('Repeat');

        });

        it('Rule 9: (Result: Valid | FAM Cq: Any) -> `(Blank)` ', function() {
          this.$scope.twoKits = true;
          
        });

      });

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
