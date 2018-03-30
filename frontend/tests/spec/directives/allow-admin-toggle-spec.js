describe("Testing allowAdminToggle", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            _$compile = $injector.get('$compile');

            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond({});

            var elem = angular.element('<allow-admin-toggle></allow-admin-toggle>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.$digest();
            compiledScope = compiled.isolateScope();

        });
    });

    it("It should test initial values", function() {
        
        expect(compiledScope.show).toEqual(true);
    });

    it("It should test change in data", function() {

        spyOn(compiledScope, "configureSwitch").and.returnValue(true);
        compiledScope.data = "admin";
        compiledScope.$digest();
        expect(compiledScope.configureSwitch).toHaveBeenCalled();
    });

    it("It should test clickHandler method", function() {

        spyOn(compiledScope, "sendData").and.returnValue(true);
        compiledScope.clickHandler();
        expect(compiledScope.sendData).toHaveBeenCalled();
    });

    it("It should test configureSwitch method when user.role === admin", function() {

        compiledScope.configureSwitch("admin");
        expect(angular.element(compiledScope.dragElem).parent().css("background-color")).toEqual("rgb(141, 198, 63)");
    });

    it("It should test configureSwitch method when user.role === user", function() {

        compiledScope.configureSwitch("admin");
        expect(angular.element(compiledScope.dragElem).parent().css("background-color")).toEqual("rgb(141, 198, 63)");
    });

    it("It should test processMovement method", function() {

        compiledScope.data = 'admin';
        spyOn(compiledScope, "sendData").and.returnValue(true);
        compiledScope.$digest();
        var pos = 1;
        var val = "user";
        compiledScope.processMovement(pos, val);
        expect(compiledScope.sendData).toHaveBeenCalled();
    });

    it("It should test processMovement method when pos > 6", function() {

        compiledScope.data = 'admin';
        spyOn(compiledScope, "sendData").and.returnValue(true);
        compiledScope.$digest();
        var pos = 8;
        var val = "user";
        compiledScope.processMovement(pos, val);
        expect(compiledScope.sendData).toHaveBeenCalled();
    });

    it("It should test sendData method", function() {

        compiledScope.data = 'admin';
        compiledScope.$digest();
        compiledScope.sendData();
        expect(compiledScope.data).toEqual("default");
    });

    it("It should test sendData method, when data !== admin", function() {

        compiledScope.data = 'smething else';
        compiledScope.$digest();
        compiledScope.sendData();
        expect(compiledScope.data).toEqual("admin");
    });
});