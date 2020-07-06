
describe("Testing TestKit Service", function() {

  var _testKitService;

  beforeEach(function() {
    module('ChaiBioTech', function($provide) {
      mockCommonServices($provide);
    });

    inject(function($injector) {
      _testKitService = $injector.get('Testkit');
    });

  });


  it("It should test getCoronaResultArray method for Valid mode", function() {
    var famCq = [1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    var hexCq = [0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    _testKitService.getCoronaResultArray(famCq, hexCq);

    expect(_testKitService.result[0]).toEqual("Valid");
    expect(_testKitService.result[1]).toEqual("Valid");
    expect(_testKitService.result[2]).toEqual("Positive");
    expect(_testKitService.result[3]).toEqual("Positive");
    expect(_testKitService.result[4]).toEqual("Not Detected");
    expect(_testKitService.result[5]).toEqual("Inhibited");

  });

  it("It should test getCoronaResultArray method for Invalid mode", function() {

    var famCq = [0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    var hexCq = [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    _testKitService.getCoronaResultArray(famCq, hexCq);

    expect(_testKitService.result[0]).toEqual("Invalid");
    expect(_testKitService.result[1]).toEqual("Invalid");
    expect(_testKitService.result[2]).toEqual("Invalid - NTC Control Failed");
    expect(_testKitService.result[3]).toEqual("Invalid - NTC Control Failed");
    expect(_testKitService.result[4]).toEqual("Invalid - Positive Control Failed");
    expect(_testKitService.result[5]).toEqual("Inhibited");

  });

});
