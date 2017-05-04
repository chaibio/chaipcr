(function() {
  'use strict'

  describe('Testing HomeCtrl', function() {

    beforeEach(function() {

      module('ChaiBioTech', function($provide) {
        mockCommonServices($provide)
      })

      inject(function($injector) {
        this.window = $injector.get('$window')
        this.Experiment = $injector.get('Experiment')
        this.controller = $injector.get('$controller')
        this.rootScope = $injector.get('$rootScope')
        this.uibModal = $injector.get('$uibModal')
        this.state = $injector.get('$state')
        this.scope = this.rootScope.$new()
        this.HomeCtrl = this.controller('HomeCtrl', {
          $scope: this.scope
        })
      })

    })

    it('should add modal-form class to body', function() {
      expect($('body').hasClass('modal-form')).toBe(true)
    })

    it('should remove modal-form class from body', function() {
      this.scope.$destroy()
      expect($('body').hasClass('modal-form')).toBe(false)
    })

    it('should have current user', function() {
      expect(this.scope.user).toEqual(userMock)
    })

    it('should fetch all experiments upon controller instantiation', function() {
      expect(this.scope.experiments).toEqual(experimentsMock)
    })

    it('should fetch all experiments on experiment completed', function() {
      spyOn(this.HomeCtrl, 'fetchExperiments')
      this.scope.enterHome = false
      this.scope.$broadcast('status:experiment:completed')
      expect(this.HomeCtrl.fetchExperiments).toHaveBeenCalled()
    })

    it('should open test kit modal', function() {
      spyOn(this.uibModal, 'open').and.callThrough()
      this.HomeCtrl.newTestKit()
      expect(this.uibModal.open).toHaveBeenCalledWith({
        templateUrl: 'app/views/experiment/create-testkit-experiment.html',
        controller: 'CreateTestKitCtrl',
        openedClass: 'modal-open-testkit',
        backdrop: false
      })
    })

    it('should open create new experiment', function() {
      spyOn(this.uibModal, 'open').and.returnValue({
        result: {
          then: function(fn) {
            fn({ id: 1 })
          }
        }
      })
      spyOn(this.state, 'go').and.callThrough()
      this.HomeCtrl.newExperiment()
      expect(this.uibModal.open).toHaveBeenCalledWith({
        templateUrl: 'app/views/experiment/create-experiment-name-modal.html',
        controller: 'CreateExperimentModalCtrl',
        backdrop: false
      })
      expect(this.state.go).toHaveBeenCalledWith('edit-protocol', { id: 1 })
    })

    it('should delete experiment', function() {
      spyOn(this.Experiment, 'delete').and.callFake(function() {
        return {
          then: function(fn) {
            fn()
            return {
              catch: function(fn) {}
            }
          }
        }
      })
      this.HomeCtrl.deleteExperiment(experimentsMock[0])
      expect(this.scope.experiments.length).toBe(0)
    })

    it('should alert error on delete experiment', function() {
      var experimentErrorBaseMock = 'Fake experiment error'
      spyOn(this.window, 'alert')
      spyOn(this.Experiment, 'delete').and.callFake(function() {
        return {
          then: function(fn) {
            return {
              catch: function(fn) {
                fn({
                  data: {
                    experiment: {
                      errors: {
                        base: experimentErrorBaseMock
                      }
                    }
                  }
                })
              }
            }
          }
        }
      })
      this.HomeCtrl.deleteExperiment(experimentsMock[0])
      expect(this.window.alert).toHaveBeenCalledWith(experimentErrorBaseMock)
    })

    it('should confirm delete', function() {
      var exp = {}
      this.scope.deleteMode = true
      this.HomeCtrl.confirmDelete(exp)
      expect(exp.del).toBe(true)
    })

  })

})();
