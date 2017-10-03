describe("Testing userFormErrors", function() {

  var _userFormErrors;

  beforeEach(function() {
    module('ChaiBioTech', function($provide) {
      mockCommonServices($provide)
    });

    inject(function($injector) {
      _userFormErrors = $injector.get('userFormErrors');
    });
  });

  it("It should test handleError method", function() {

    $scope = {

    };

    var problem = {
      errors: {
        email: [
          'is invalid'
        ]
      }
    };

    var form = {
      emailField: {
        $setValidity: function() {

        }
      }
    };

    spyOn(form.emailField, "$setValidity");
    _userFormErrors.handleError($scope, problem, form);
    expect(form.emailField.$setValidity).toHaveBeenCalledWith("emailInvalid", false);
  });

  it("It should test handleError method when email is already taken", function() {

    $scope = {

    };

    var problem = {
      errors: {
        email: [
          'is already taken'
        ]
      }
    };

    var form = {
      emailField: {
        $setValidity: function() {

        }
      }
    };

    spyOn(form.emailField, "$setValidity");
    _userFormErrors.handleError($scope, problem, form);
    expect(form.emailField.$setValidity).toHaveBeenCalledWith("emailAlreadtTaken", false);
  });

});
