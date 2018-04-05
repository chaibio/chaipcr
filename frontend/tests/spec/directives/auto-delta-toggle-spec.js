describe("Testing autoDeltaToggle", function() {

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
            httpMock.whenGET("/experiments/10").respond("NOTHING");
            var obj = {
                val: "good"
            };
            var elem = angular.element('<auto-delta-toggle data="obj.val" type="cycling"></auto-delta-toggle>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        compiledScope.$emit('dataLoaded');
        spyOn(compiledScope, "configureSwitch").and.returnValue(true);
        
        compiledScope.$apply(function() {
            compiledScope.data = "new Data";
            compiledScope.type = "cycling";
        });
        
        compiledScope.$digest();
        expect(compiledScope.show).toEqual(true);
        expect(compiledScope.configureSwitch).toHaveBeenCalled();
    });

    it("It should test initial values / differnt initial values", function() {

        compiledScope.$emit('dataLoaded');
        spyOn(compiledScope, "configureSwitch").and.returnValue(true);
        
        compiledScope.$apply(function() {
            compiledScope.data = "new Data";
            compiledScope.type = "holding";
        });
        
        compiledScope.$digest();
        expect(compiledScope.show).toEqual(false);
        expect(compiledScope.configureSwitch).toHaveBeenCalled();
    });

    it("It should test clickHandler method", function() {

        spyOn(compiledScope, "configureSwitch").and.returnValue(true);
        spyOn(compiledScope, "sendData").and.returnValue(true);

        compiledScope.clickHandler();

        expect(compiledScope.configureSwitch).toHaveBeenCalled();
        expect(compiledScope.sendData).toHaveBeenCalled();
    });

    it("It should test configureSwitch method, when we pass true", function() {

        var val = true;

        compiledScope.configureSwitch(val);

        expect($(compiledScope.dragElem).parent().css("background-color")).toEqual('rgb(141, 198, 63)');
    });

    it("It should test configureSwitch method, when we pass false", function() {

        var val = false;

        compiledScope.configureSwitch(val);

        expect($(compiledScope.dragElem).parent().css("background-color")).toEqual('rgb(187, 187, 187)');
    });

    it("It should test sendData method", function() {

        compiledScope.$parent = [
            function() {
                return true;
            },
        ];

        compiledScope.call = 0;

        compiledScope.sendData();

        expect(compiledScope.data).toEqual(true);
    });

    
});