describe("Testing User service", function() {

    var _$http, _$q, _User, $httpBackend;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

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
            _$q = $injector.get('$q');
            _User = $injector.get('User');
        });

        $.jStorage.set('id', 'jossie');
    });

    it("It should test currentUser mrthod", function() {
        //expect(1).toEqual(2);
        var uData = _User.currentUser();
        console.log(uData);

    });

    it("It should test save method", function() {
        var user = {
            name: "Chai"
        };
        var url = '/users';
        spyOn(_$http, "post").and.callThrough();
        $httpBackend.expectPOST(url).respond({data: {
            user: "Chai"
        }});
        _User.save();
        $httpBackend.flush();
        expect(_$http.post).toHaveBeenCalled();
    });

    it("It should test save method, when request fails", function() {
        var user = {
            name: "Chai"
        };
        var url = '/users';
        spyOn(_$http, "post").and.callThrough();
        $httpBackend.expectPOST(url).respond(502);
        _User.save();
        $httpBackend.flush();
        expect(_$http.post).toHaveBeenCalled();
    });

    it("It should test getCurrent method", function() {

        var url = '/users/current';
        spyOn(_$http, "get").and.callThrough();
        $httpBackend.expectGET(url).respond({
            'userName': "Chai"
        });

        var val;

         _User.getCurrent().then(function(userInfo) {
            val =  userInfo.data;
        });

        $httpBackend.flush();
        expect(_$http.get).toHaveBeenCalled();
        expect(val.userName).toEqual("Chai");
        
    });

    it("It should test fetch method", function() {

        var url = '/users';
        spyOn(_$http, "get").and.callThrough();
        $httpBackend.expectGET(url).respond({ data: {}});
        _User.fetch();
        $httpBackend.flush();
        expect(_$http.get).toHaveBeenCalled();
    });

    it("It should test updateUser method", function() {

        var id = 10;
        var data = {}; 
        var url = "/users/" + id;
        spyOn(_$http, "put").and.callThrough();
        $httpBackend.expectPUT(url).respond({data: {
            user: {
                id: 10
            }
        }});
        _User.updateUser(id, data);
        $httpBackend.flush();
        expect(_$http.put).toHaveBeenCalled();
    });

    it("It should test updateUser method, when request fails", function() {

        var id = 10;
        var data = {}; 
        var url = "/users/" + id;
        spyOn(_$http, "put").and.callThrough();
        $httpBackend.expectPUT(url).respond(502, { data: {
            user: {
                id: 10
            }
        }});

        _User.updateUser(id, data);
        $httpBackend.flush();
        expect(_$http.put).toHaveBeenCalled();
    });

    it("It should test findUSer method", function() {

        var key = 10;
        var url = '/users/' + key;
        spyOn(_$http, "get").and.callThrough();
        $httpBackend.expectGET(url).respond(200, {
            data: {
                id: 10
            }
        });

        _User.findUSer(key);
        $httpBackend.flush();
        expect(_$http.get).toHaveBeenCalled();
    });

    it("It should test remove method", function() {

        var id = 10;
        var url = "/users/" + id;
        spyOn(_$http, "delete").and.callThrough();
        $httpBackend.expectDELETE(url).respond(200, {
            data: {
                id: 10
            }
        });

        _User.remove(id);
        $httpBackend.flush();
        expect(_$http.delete).toHaveBeenCalled();
    });
});