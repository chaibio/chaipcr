describe('PikaTest Two TestKit Result', function() {
  beforeEach(module('PikaTest'));

  var $controller, $rootScope;

  beforeEach(inject(function(_$controller_, _$rootScope_){
    // The injector unwraps the underscores (_) from around the parameter names when matching
    $controller = _$controller_;
    $rootScope = _$rootScope_;
  }));

  describe('Positive Control Result', function() {
    it('Rule 1: (20 <= FAM Cq <= 34 | HEX Cq = Any) -> `Valid` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;      

      scope.famCq[8] = 19;
      controller.getResultArray();
      expect(scope.result[8]).toEqual('Invalid');

      scope.famCq[8] = 25;
      controller.getResultArray();
      expect(scope.result[8]).toEqual('Valid');

      scope.famCq[8] = 35;
      controller.getResultArray();
      expect(scope.result[8]).toEqual('Invalid');
    });

    it('Rule 2: All Other Cases -> `Invalid` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      scope.famCq[8] = 19;
      controller.getResultArray();
      expect(scope.result[8]).toEqual('Invalid');

      scope.famCq[8] = 35;
      controller.getResultArray();
      expect(scope.result[8]).toEqual('Invalid');
    });

  });

  describe('Negative Control Result', function() {
    it('Rule 1: ( FAM Cq is Blank | 20 <= HEX Cq <= 36) -> `Valid` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      scope.famCq[9] = null;
      scope.hexCq[9] = 25;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');

      scope.famCq[9] = null;
      scope.hexCq[9] = 20;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');

      scope.famCq[9] = null;
      scope.hexCq[9] = 36;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');
    });

    it('Rule 2: ( 38 < FAM Cq <= 40 | 20 <= HEX Cq <= 36) -> `Valid` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      scope.famCq[9] = 39;
      scope.hexCq[9] = 25;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');

      scope.famCq[9] = 39;
      scope.hexCq[9] = 20;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');

      scope.famCq[9] = 39;
      scope.hexCq[9] = 36;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');

      ////////////////////////////////////////////////
      scope.famCq[9] = 40;
      scope.hexCq[9] = 25;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');

      scope.famCq[9] = 40;
      scope.hexCq[9] = 20;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');

      scope.famCq[9] = 40;
      scope.hexCq[9] = 36;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Valid');

    });

    it('Rule 3: All Other Cases -> `Invalid` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      scope.famCq[9] = null;
      scope.hexCq[9] = 19;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Invalid');

      scope.famCq[9] = null;
      scope.hexCq[9] = 37;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Invalid');

      ////////////////////////////////////////////////

      scope.famCq[9] = 38;
      scope.hexCq[9] = 20;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Invalid');

      scope.famCq[9] = 41;
      scope.hexCq[9] = 36;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Invalid');

      ////////////////////////////////////////////////

      scope.famCq[9] = 38;
      scope.hexCq[9] = 36;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Invalid');

      scope.famCq[9] = 41;
      scope.hexCq[9] = 20;
      controller.getResultArray();
      expect(scope.result[9]).toEqual('Invalid');

      ////////////////////////////////////////////////
    });
  });

  describe('Sample Result', function() {
    it('Rule 1: (Positive: Any | Negative: Invalid | FAM Cq: Any | HEX Cq: Any) -> `Invalid` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Invalid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Invalid');

      //Positive: Valid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 36, 10];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 38, 10];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Invalid');
    });

    it('Rule 2: (Positive: Valid | Negative: Valid | 10 <= FAM Cq <= 38 | HEX Cq: Any) -> `Positive` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 10];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Positive');

      //Positive: Valid | Negative: Valid | FAM Cq: 38 | HEX Cq: Any
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 38];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Positive');

      //Positive: Valid | Negative: Valid | FAM Cq: 20 | HEX Cq: Any
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 20];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Positive');
    });

    it('Rule 3: (Positive: Valid | Negative: Valid | FAM Cq: No Cq | 20 <= HEX Cq <=36) -> `Negative` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 20
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 20];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Negative');

      //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 36
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Negative');

      //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 30
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Negative');
    });

    it('Rule 4: (Positive: Valid | Negative: Valid | FAM Cq > 38 | 20 <= HEX Cq <=36) -> `Negative` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 20
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 20];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Negative');

      //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 36
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Negative');

      //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 30
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 30];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Negative');
    });

    it('Rule 5: (Positive: Any | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq) -> `Inhibited` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, null];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Inhibited');

      //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: No Cq
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, null];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Inhibited');
    });

    it('Rule 6: (Positive: Any | Negative: Valid | FAM Cq: No Cq | HEX Cq > 36) -> `Inhibited` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 37
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Inhibited');

      //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 37
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Inhibited');
    });

    it('Rule 7: (Positive: Any | Negative: Valid | FAM Cq: > 38 | HEX Cq: No Cq) -> `Inhibited` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: No Cq
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, null];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Inhibited');

      //Positive: Invalid | Negative: Valid | FAM Cq: 39 | HEX Cq: No Cq
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, null];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Inhibited');
    });

    it('Rule 8: (Positive: Any | Negative: Valid | FAM Cq: > 38 | HEX Cq > 36) -> `Inhibited` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Inhibited');

      //Positive: Invalid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Inhibited');
    });

    it('Rule 9: All Other Cases -> `Invalid` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Invalid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 36
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Invalid');

      //Positive: Valid | Negative: Valid | FAM Cq: 9 | HEX Cq: 36
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 9];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Invalid');

      //Positive: Invalid | Negative: Valid | FAM Cq: 38 | HEX Cq: No Cq
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 39, 38];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 36];
      controller.getResultArray();
      expect(scope.result[10]).toEqual('Invalid');
    });
  });

  describe('Concentration Amount', function() {
    it('Rule 1: (Result: Positive | FAM Cq: < 10) -> `N/A` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 10];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];
    });

    it('Rule 2: (Result: Positive | 10 <= FAM Cq: <= 24) -> `High` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 10];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

      controller.getResultArray();
      expect(scope.amount[10]).toEqual('High');

      //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 24];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

      controller.getResultArray();
      expect(scope.amount[10]).toEqual('High');

    });

    it('Rule 3: (Result: Positive | 24 < FAM Cq: <= 30) -> `Medium` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 25];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

      controller.getResultArray();
      expect(scope.amount[10]).toEqual('Medium');

      //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 30];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

      controller.getResultArray();
      expect(scope.amount[10]).toEqual('Medium');

    });

    it('Rule 4: (Result: Positive | 30 < FAM Cq: <= 38) -> `Low` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 31];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

      controller.getResultArray();
      expect(scope.amount[10]).toEqual('Low');

      //Positive: Valid | Negative: Valid | FAM Cq: 24 | HEX Cq: Any -> Positive
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 38];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

      controller.getResultArray();
      expect(scope.amount[10]).toEqual('Low');

    });

    it('Rule 5: (Result: Positive | FAM Cq: > 38) -> `N/A` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 10 | HEX Cq: Any -> Positive
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 31];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 10];

    });

    it('Rule 6: (Result: Negative | FAM Cq: Any) -> `Not Detectable` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: No Cq | HEX Cq: 20
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, null];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 20];
      controller.getResultArray();
      expect(scope.amount[10]).toEqual('Not Detectable');

      //Positive: Valid | Negative: Valid | FAM Cq: 37 | HEX Cq: 20
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 20];
      controller.getResultArray();
      expect(scope.amount[10]).toEqual('Not Detectable');

    });

    it('Rule 7: (Result: Inhibited | FAM Cq: Any) -> `Repeat` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Valid | Negative: Valid | FAM Cq: 39 | HEX Cq: 37
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 20, 39, 39];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 10, 20, 37];
      controller.getResultArray();
      expect(scope.amount[10]).toEqual('Repeat');

    });

    it('Rule 8: (Result: Invalid | FAM Cq: Any) -> `Repeat` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;

      //Positive: Invalid | Negative: Invalid | FAM Cq: Any | HEX Cq: Any
      scope.famCq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      scope.hexCq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      controller.getResultArray();
      expect(scope.amount[10]).toEqual('Repeat');

    });

    it('Rule 9: (Result: Valid | FAM Cq: Any) -> `(Blank)` ', function() {
      var scope = $rootScope.$new();
      var controller = $controller('AppController', { $scope: scope });
      scope.twoKits = true;
      
    });

  });
});