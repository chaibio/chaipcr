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
});