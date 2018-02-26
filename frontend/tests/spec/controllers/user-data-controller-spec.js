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

  it("It should test update method", function() {

    var form = {
      $valid: true
    };

    _$scope.userData = {
      password: "chaibio",
      password_confirmation: "chaibio"
    };

    _userService.updateUser = function() {
      return {
        then: function(callback) {
          callback();
        }
      };
    };
  
    _$state.is = function() {
      return true;
    };

    _$state.transitionTo = function() {
      return true;
    };

    spyOn(_userService, "updateUser").and.callThrough();
    spyOn(_$state, "is").and.callThrough();
    spyOn(_$state, "transitionTo");

    _$scope.update(form);

    expect(_userService.updateUser).toHaveBeenCalled();
    expect(_$state.is).toHaveBeenCalled();
    expect(_$state.transitionTo).toHaveBeenCalledWith('settings.root', jasmine.any(Object), jasmine.any(Object));

  });

  it("It should test update method when $state.is() method return false", function() {

    var form = {
      $valid: true
    };

    _$scope.userData = {
      password: "chaibio",
      password_confirmation: "chaibio"
    };

    _userService.updateUser = function() {
      return {
        then: function(callback) {
          callback();
        }
      };
    };
  
    _$state.is = function() {
      return false;
    };

    _$state.transitionTo = function() {
      return true;
    };

    spyOn(_userService, "updateUser").and.callThrough();
    spyOn(_$state, "is").and.callThrough();
    spyOn(_$state, "transitionTo");

    _$scope.update(form);

    expect(_userService.updateUser).toHaveBeenCalled();
    expect(_$state.is).toHaveBeenCalled();
    expect(_$state.transitionTo).toHaveBeenCalledWith('settings.usermanagement', jasmine.any(Object), jasmine.any(Object));

  });

  it("It should test update method when error callback is called", function() {

    var form = {
      $valid: true
    };

    _$scope.userData = {
      password: "chaibio",
      password_confirmation: "chaibio"
    };

    _userService.updateUser = function() {
      return {
        then: function(callback, errorCallback) {
          errorCallback();
        }
      };
    };
    
    _userFormErrors.handleError = function() {

    };

    _$state.is = function() {
      return false;
    };

    _$state.transitionTo = function() {
      return true;
    };

    spyOn(_userService, "updateUser").and.callThrough();
    spyOn(_$state, "is").and.callThrough();
    spyOn(_$state, "transitionTo");
    spyOn(_userFormErrors, "handleError").and.callThrough();

    _$scope.update(form);

    expect(_userService.updateUser).toHaveBeenCalled();
    expect(_$state.is).not.toHaveBeenCalled();
    expect(_$state.transitionTo).not.toHaveBeenCalledWith('settings.usermanagement', jasmine.any(Object), jasmine.any(Object));
    expect(_userFormErrors.handleError).toHaveBeenCalled();
  });

  it("It should test comparePass method", function() {
     
     _$scope.userData = {
        password: "chaibio",
        password_confirmation: "chaibio"
      };

      var form = {
        password: {
          $setValidity: function() {}
        },
        confirmPassword: {
          $setValidity: function() {}
        }
      };

      spyOn(form.password, "$setValidity");
      spyOn(form.confirmPassword, "$setValidity");

      _$scope.comparePass(form);

      expect(form.password.$setValidity).toHaveBeenCalledWith('confirmPassword', true);
      expect(form.confirmPassword.$setValidity).toHaveBeenCalledWith('confirmPassword', true);

  });

  it("It should test comparePass method when passwords are not mactching", function() {
     
     _$scope.userData = {
        password: "chaibio",
        password_confirmation: "chaibio tech"
      };

      var form = {
        password: {
          $setValidity: function() {}
        },
        confirmPassword: {
          $setValidity: function() {}
        }
      };

      spyOn(form.password, "$setValidity");
      spyOn(form.confirmPassword, "$setValidity");

      _$scope.comparePass(form);

      expect(form.password.$setValidity).not.toHaveBeenCalledWith('confirmPassword', true);
      expect(form.confirmPassword.$setValidity).not.toHaveBeenCalledWith('confirmPassword', true);

      expect(form.password.$setValidity).toHaveBeenCalledWith('confirmPassword', false);
      expect(form.confirmPassword.$setValidity).toHaveBeenCalledWith('confirmPassword', false);
      
  });

  it("It should test emailKeyDown method", function() {

    var form = {
        password: {
          $setValidity: function() {}
        },
        confirmPassword: {
          $setValidity: function() {}
        },
        emailField: {
          $setValidity: function() {}
        }
      };

      spyOn(form.emailField, "$setValidity");

      _$scope.emailKeyDown(form);

      expect(form.emailField.$setValidity).toHaveBeenCalledWith('emailAlreadtTaken', true);

  });

  it("It should test deleteMessage", function() {
    
    _$uibModal.open = function() {
      return "uiModal open";
    };

    spyOn(_$uibModal, "open").and.callThrough();

    _$scope.deleteMessage();

    expect(_$uibModal.open).toHaveBeenCalled();
    expect(_$scope.uiModal).toEqual("uiModal open");

  });

});
