describe("Testing delete-mode directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _HomePageDelete;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            _$compile = $injector.get('$compile');
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _canvas = $injector.get('canvas');
            _$timeout = $injector.get('$timeout');
            _HomePageDelete = $injector.get('HomePageDelete');
            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");

            var stage = {
                auto_delta: true
            };

            var step = {
                delta_duration_s: 10
            };
            var elem = angular.element('<delete-mode func="changeDeltaTime" delta="10" data="15"></delete-mode>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.deleteClicked).toEqual(false);
        expect(compiledScope.running).toEqual(false);
        expect(compiledScope.deleting).toEqual(false);
    });

    it("It should test the $watch deleteMode", function() {

        compiledScope.deleteMode = false;
        compiledScope.deleteClicked = true;

        spyOn(compiledScope, "reset").and.returnValue(true);

        compiledScope.$digest();

        expect(compiledScope.reset).toHaveBeenCalled();
    });

    it("It should test $watch experiment", function() {
        var exp = {
            started_at: '6/04/2018',
            completed_at: '06/04/2018'
        };

        compiledScope.experiment = exp;

        compiledScope.$digest();

        expect(compiledScope.running).toEqual(false);
    });

    it("It should test deleteClickedHandle method", function() {
        _HomePageDelete.deactiveate = function() {

        };
        spyOn(_HomePageDelete, "deactiveate").and.returnValue();

        compiledScope.running = false;
        compiledScope.$digest();

        compiledScope.deleteClickedHandle();

        expect(_HomePageDelete.deactiveate).toHaveBeenCalled();
    });

    it("It should test deleteClickedHandle method when deleteClicked is false", function() {

        _HomePageDelete.deactiveate = function() {

        };
        spyOn(_HomePageDelete, "deactiveate").and.returnValue();

        compiledScope.running = false;
        compiledScope.deleteClicked = true;
        compiledScope.$digest();

        compiledScope.deleteClickedHandle();
        
        expect(_HomePageDelete.deactiveate).toHaveBeenCalled();
    });

    it("It should test reset method", function() {

        compiledScope.reset();
        expect(compiledScope.deleteClicked).toEqual(false);
    });

    it("It should test tryDeletion method", function() {

        compiledScope.deleteExp = function() {

        };

        spyOn(compiledScope, "deleteExp");

        compiledScope.tryDeletion();

        expect(compiledScope.deleting).toEqual(true);
        expect(compiledScope.deleteClicked).toEqual(true);
        expect(compiledScope.deleteExp).toHaveBeenCalled();
    });
});