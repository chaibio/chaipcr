describe("Testing newUserController", function() {

    var _$scope, _$stateParams, _User, _$state, _$uibModal, _userFormErrors, newUserController, controlle, _$rootScope;

    beforeEach(function() {
        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
            $provide.value('$stateParams', {
                id: 100
            });
        });

        inject(function($injector) {
            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            //_$stateParams = $injector.get('$stateParams');
            _User = $injector.get('User');
            _$state = $injector.get('$state');
            _$uibModal = $injector.get('$uibModal');
            _userFormErrors = $injector.get('userFormErrors');
            _$controller = $injector.get('$controller');
            
            newUserController = _$controller('newUserController', {
                $scope: _$scope
            });

            //_$stateParams.id = 100;
        });
    });

    it("It should test initial values", function() {
        console.log(_$scope);
        expect(_$scope.id).toBe(100);
    });


});