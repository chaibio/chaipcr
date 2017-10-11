describe("Testing supportAccessService", function() {

  var _$q, _$http, _supportAccessService, $httpBackend;

  beforeEach(function() {

    module('ChaiBioTech', function($provide) {
      mockCommonServices($provide)
    });

    inject(function($injector) {

      $httpBackend = $injector.get('$httpBackend');
      $httpBackend.whenGET("http://localhost:8000/status").respond("NOTHING");
      $httpBackend.whenGET("http://localhost:8000/network/wlan").respond({
        data: {
          state: {
            macAddress: "125",
            status: {

            }
          }
        }
      });
      _$q = $injector.get('$q');
      _$http = $injector.get('$http');
      _supportAccessService = $injector.get('supportAccessService');
    });

  });

  it("It should test accessSupport method", function() {

    var url = '/device/enable_support_access';
    spyOn(_$http, 'post').and.callThrough();
    $httpBackend.expectPOST(url).respond(200);
    _supportAccessService.accessSupport();
    $httpBackend.flush();
    expect(_$http.post).toHaveBeenCalled();
  });

  it("It should test accessSupport method, when request fail", function() {

    var url = '/device/enable_support_access';
    spyOn(_$http, 'post').and.callThrough();
    $httpBackend.expectPOST(url).respond(500);
    _supportAccessService.accessSupport();
    $httpBackend.flush();
    expect(_$http.post).toHaveBeenCalled();
  });
});
