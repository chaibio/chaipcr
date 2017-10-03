describe("Testing Protocol service", function() {

  var _$http, _Protocol, $httpBackend;

  beforeEach(function() {

    module('ChaiBioTech', function($provide) {
      $provide.value('IsTouchScreen', function () {})
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

      _$http = $injector.get('$http');
      _Protocol = $injector.get('Protocol');
    });

  });

  it("It should test update method", function() {

    var data = {
      id: 10
    };
    spyOn(_$http, 'put').and.callThrough();
    var url = "/protocols/" + data.id;

    $httpBackend.expectPUT(url).respond(200);

    _Protocol.update(data);
    expect(_$http.put).toHaveBeenCalled();
    $httpBackend.flush();


  });

});
