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
        expect(_$scope.userData).toEqual(jasmine.any(Object));
        expect(_$scope.resetPassStatus).toBe(true);
        expect(_$scope.isAdmin).toBe(false);
        expect(_$scope.allowEditPassword).toEqual(true);
        expect(_$scope.allowButtons).toEqual(true);
        expect(_$scope.passError).toEqual(false);
        expect(_$scope.passLengthError).toEqual(false);
        expect(_$scope.emailAlreadtTaken).toEqual(false);
        expect(_$scope.editable).toEqual(true);


    });

    it("It should test uodate method, test the success callback of save", function() {

        var form  = {
            $valid: true,

        };

        _User.save = function() {
            return {
                then: function(success, error) {
                    success();
                }
            };
        };

        spyOn(_$state, "transitionTo");
        
        _$scope.update(form);
        expect(_$state.transitionTo).toHaveBeenCalled();
    });

    it("It should test uodate method, test the error callback of save", function() {

        var form  = {
            $valid: true,

        };

        _User.save = function() {
            return {
                then: function(success, error) {
                    var err = {
                        user: {

                        }
                    };
                    error(err);
                }
            };
        };

        spyOn(_userFormErrors, "handleError");
        
        _$scope.update(form);
        expect(_userFormErrors.handleError).toHaveBeenCalled();
    });

    it("It should test emailKeyDown method", function() {

        var form = {
            emailField: {

                $setValidity: function() {

                }
            }
        };

        spyOn(form.emailField, "$setValidity");
        _$scope.emailKeyDown(form);
        expect(form.emailField.$setValidity).toHaveBeenCalled();
    });

    it("It should test comparePass method, when passwords dont match", function() {

        _$scope.userData.password = "okay";
        _$scope.userData.password_confirmation = "not okay";

        var form = {
            password: {
                $setValidity: function() {},
            },
            confirmPassword: {
                $setValidity: function() {}
            }
        };

        spyOn(form.password, "$setValidity");
        spyOn(form.confirmPassword, "$setValidity");

        _$scope.comparePass(form);

        expect(form.password.$setValidity).toHaveBeenCalled();
        expect(form.confirmPassword.$setValidity).toHaveBeenCalledWith("confirmPassword", false);
    });

    it("It should test comparePass method, when passwords match", function() {

        _$scope.userData.password = "okay";
        _$scope.userData.password_confirmation = "okay";

        var form = {
            password: {
                $setValidity: function() {},
            },
            confirmPassword: {
                $setValidity: function() {}
            }
        };

        spyOn(form.password, "$setValidity");
        spyOn(form.confirmPassword, "$setValidity");

        _$scope.comparePass(form);

        expect(form.password.$setValidity).toHaveBeenCalledWith("confirmPassword", true);
        expect(form.confirmPassword.$setValidity).toHaveBeenCalledWith("confirmPassword", true);
    });

    it("It should test currentLogin method, when user is admin", function() {
       
         _User.findUSer = function() {
            return {
                then: function(callback) {
                    var data = {
                        user: {
                            role: "admin"
                        }
                    };
                    callback(data);
                }
            };
         }; 
       _$scope.currentLogin();

        expect(_$scope.isAdmin).toEqual(true); 
    });

    it("It should test currentLogin method, when user is not admin", function() {
       
         _User.findUSer = function() {
            return {
                then: function(callback) {
                    var data = {
                        user: {
                            role: "user"
                        }
                    };
                    callback(data);
                }
            };
         }; 
       _$scope.currentLogin();

        expect(_$scope.isAdmin).toEqual(false); 
    });
    
});