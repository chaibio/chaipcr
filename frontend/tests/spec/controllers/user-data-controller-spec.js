describe("Testing userDataController", function() {

  var _$scope, rootScope, _$stateParams, _userService, _$state, _$uibModal, _userFormErrors, _userDataController, _$controller;

  beforeEach(function() {

      module('ChaiBioTech', function($provide) {
          $provide.value('IsTouchScreen', function () {});
      });

      inject(function($injector) {

          _$rootScope = $injector.get('$rootScope');
          _$scope = _$rootScope.$new();
          _$stateParams = $injector.get('$stateParams');
          _userService = $injector.get('User');
          _$state = $injector.get('$state');
          _$uibModal = $injector.get('$uibModal');
          _userFormErrors = $injector.get('userFormErrors');
          _$controller = $injector.get('$controller');
          
          _userDataController = _$controller('userDataController', {
            $scope: _$scope
          });
      });
  });

  it("It should test initial values", function() {

      expect(_$scope.resetPassStatus).toEqual(false);
      expect(_$scope.id).toEqual(_$stateParams.id);
      expect(_$scope.resetPassStatus).toEqual(false);
      expect(_$scope.userData.password).toEqual("");
      expect(_$scope.userData.password_confirmation).toEqual("");
      expect(_$scope.isAdmin).toEqual(false);
      expect(_$scope.allowEditPassword).toEqual(false);
      expect(_$scope.allowButtons).toEqual(false);
      expect(_$scope.passError).toEqual(false);
      expect(_$scope.cancelButton).toEqual(true);
      expect(_$scope.deleteButton).toEqual(true);
      expect(_$scope.emailAlreadtTaken).toEqual(false);
      expect(_$scope.editable).toEqual(false);
      expect(_$scope.allowToggleAdmin).toEqual(false);
  });

  it("It should test getUserData method", function() {

    _userService.findUSer = function() {
      return {
        then: function(callback) {
          var data = {
            user: {
              id: 100
            }
          };
          callback(data);
        }
      };
    };

    spyOn(_userService, "findUSer").and.callThrough();

    _$scope.getUserData();

    expect(_userService.findUSer).toHaveBeenCalled();
    expect(_$scope.id).toEqual(100);
  });

  it("It should test currentLogin method", function() {

      _userService.findUSer = function() {
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

      spyOn(_userService, "findUSer").and.callThrough();

      _$scope.currentLogin();

      expect(_userService.findUSer).toHaveBeenCalled();
      expect(_$scope.isAdmin).toEqual(true);
      expect(_$scope.allowEditPassword).toEqual(true);
      expect(_$scope.allowButtons).toEqual(true);
      expect(_$scope.editable).toEqual(true);
      expect(_$scope.allowToggleAdmin).toEqual(true);
  });
  
  it("It should test currentLogin method", function() {

      _userService.findUSer = function() {
          return {
            then: function(callback) {
              var data = {
                user: {
                  role: "admin",
                  id: 10
                }
              };

              callback(data);
            }
          };
      };
      
      spyOn(_userService, "findUSer").and.callThrough();
      spyOn(_$state, "is").and.returnValue(true);

      _$scope.currentLogin();

      expect(_userService.findUSer).toHaveBeenCalled();
      expect(_$scope.isAdmin).toEqual(true);
      expect(_$scope.allowEditPassword).toEqual(true);
      expect(_$scope.allowButtons).toEqual(true);
      expect(_$scope.deleteButton).toEqual(false);
      expect(_$scope.editable).toEqual(true);
      expect(_$scope.allowToggleAdmin).toEqual(false);
  });

  it("It should test resetPass method", function() {
    _$scope.userData = {

    };

    _$scope.resetPass();

    expect(_$scope.userData.password).toEqual("");
    expect(_$scope.userData.password_confirmation).toEqual("");
    expect(_$scope.resetPassStatus).toEqual(true);
  });

  it("It should test deleteUser method", function() {

    _userService.remove = function() {
      return {
        then: function(callback) {
          callback();
        }
      };
    };

    spyOn(_userService, "remove").and.callThrough();
    spyOn(_$state, "go").and.returnValue(true);

    _$scope.deleteUser();

    expect(_userService.remove).toHaveBeenCalled();
    expect(_$state.go).toHaveBeenCalled();
  });
});
