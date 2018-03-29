describe("Testing action directive", function() {

    var _ExperimentLoader, _$timeout, _canvas, _popupStatus, _editModeService, _actions, $compile, compiledScope, _$scope;

    
    beforeEach(function() {
        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _$rootScope = $injector.get('$rootScope');
            _User = $injector.get('User');
            _ExperimentLoader =$injector.get('ExperimentLoader');
            _$timeout = $injector.get('$timeout');
            _canvas = $injector.get('canvas');
            _popupStatus = $injector.get('popupStatus');
            $compile = $injector.get('$compile');
            _$scope = _$rootScope.$new();
            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond({});

        });
        
    });

    /*it("It should test it", function() {

        var elem = angular.element("<actions'></actions>");
        var compiled = $compile(elem)(_$scope);
        _$scope.$digest();
        compiledScope = compiled.scope();
        console.log(compiledScope, compiledScope.addStage_);
        expect(compiledScope.actionPopup).toEqual(false);
    });*/

});