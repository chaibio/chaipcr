describe("Testing gatherDataToggle directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout;

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
            var elem = angular.element('<gather-data-toggle data="step.collect_data" call="changeDuringStep" ih="infiniteHoldStep" pus="step.pause"></gather-data-toggle></div><span ng-class="{faded: infiniteHoldStep}">STEP</span>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.isolateScope();
            
        });
    });

    it("It should test initial values", function() {

        expect(compiledScope.show).toEqual(true);
    });

    it("It should test dataLoaded event and $watch for data", function() {

        compiledScope.$emit("dataLoaded");
        spyOn(compiledScope, "configureSwitch").and.returnValue(true);
        compiledScope.data = "value";
        compiledScope.$digest();
        expect(compiledScope.configureSwitch).toHaveBeenCalled();

    });

    it("It should test dataLoaded event and $watch for pause is true", function() {

        compiledScope.$emit("dataLoaded");

        spyOn(compiledScope.dragElem, "draggable").and.returnValue(true);
        compiledScope.pause = true;
        compiledScope.$digest();
        expect(compiledScope.dragElem.draggable).toHaveBeenCalled();
    });

    it("It should test dataLoaded event and $watch for pause is false", function() {

        compiledScope.$emit("dataLoaded");

        spyOn(compiledScope.dragElem, "draggable").and.returnValue(true);
        compiledScope.pause = false;
        compiledScope.$digest();
        expect(compiledScope.dragElem.draggable).toHaveBeenCalledWith('enable');
    });

    it("It should test dataLoaded event and $watch for infiniteHoldStep is true", function() {

        compiledScope.$emit("dataLoaded");

        spyOn(compiledScope.dragElem, "draggable").and.returnValue(true);
        compiledScope.infiniteHoldStep = true;
        compiledScope.$digest();
        expect(compiledScope.dragElem.draggable).toHaveBeenCalled();
    });

    it("It should test dataLoaded event and $watch for infiniteHoldStep is false", function() {

        compiledScope.$emit("dataLoaded");

        spyOn(compiledScope.dragElem, "draggable").and.returnValue(true);
        compiledScope.infiniteHoldStep = false;
        compiledScope.$digest();
        expect(compiledScope.dragElem.draggable).toHaveBeenCalledWith('enable');
    });




});