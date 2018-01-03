(function() {
  'use strict'

  describe('Testing HomeCtrl', function() {

    beforeEach(function() {

      module('ChaiBioTech', function($provide) {
        mockCommonServices($provide)
      });

      inject(function($injector) {
        this.window = $injector.get('$window')
        this.Experiment = $injector.get('Experiment')
        this.Status = $injector.get('Status')
        this.controller = $injector.get('$controller')
        this.rootScope = $injector.get('$rootScope')
        this.uibModal = $injector.get('$uibModal')
        this.state = $injector.get('$state')
        this.scope = this.rootScope.$new()
        this.HomeCtrl = this.controller('HomeCtrl', {
          $scope: this.scope
        });
      });

    });

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

    it('should not open experiment on delete mode', function() {
      var experiment = experimentsMock[0]
      spyOn(this.Status, 'getData')
      this.scope.deleteMode = true
      this.HomeCtrl.openExperiment(experiment)
      expect(this.Status.getData).not.toHaveBeenCalled()
    })

    describe('Open Experiment', function() {

      it('should go to amplification chart', function() {
        var experiment = {
          id: 1,
          type: 'user',
          started_at: new Date().toString(),
          completed_at: null
        }
        spyOn(this.Status, 'getData').and.returnValue({
          experiment_controller: {
            machine: {
              state: 'running'
            },
            experiment: experiment
          }
        })
        spyOn(this.state, 'go')
        this.scope.deleteMode = false
        this.HomeCtrl.openExperiment(experiment)
        expect(this.Status.getData).toHaveBeenCalled()
        expect(this.state.go).toHaveBeenCalledWith('run-experiment', {
          id: experiment.id,
          chart: 'amplification'
        })
      })

      it('should go to amplification chart when already started and not completed', function() {
        var experiment = {
          id: 1,
          type: 'user',
          started_at: new Date().toString(),
          completed_at: null
        }
        spyOn(this.Status, 'getData').and.returnValue({
          experiment_controller: {
            machine: {
              state: 'idle'
            },
            experiment: experiment
          }
        })
        spyOn(this.state, 'go')
        this.scope.deleteMode = false
        this.HomeCtrl.openExperiment(experiment)
        expect(this.Status.getData).toHaveBeenCalled()
        expect(this.state.go).toHaveBeenCalledWith('run-experiment', {
          id: experiment.id,
          chart: 'amplification'
        })
      })

      it('should go to protocol screen', function() {
        var experiment = {
          id: 1,
          type: 'user',
          started_at: null,
          completed_at: null
        }
        spyOn(this.Status, 'getData').and.returnValue({
          experiment_controller: {
            machine: {
              state: 'running'
            },
            experiment: { id: 0 }
          }
        })
        spyOn(this.state, 'go')
        this.scope.deleteMode = false
        this.HomeCtrl.openExperiment(experiment)
        expect(this.Status.getData).toHaveBeenCalled()
        expect(this.state.go).toHaveBeenCalledWith('edit-protocol', {
          id: experiment.id
        })
      })

      it('should go to pika_test.setWellsA', function() {
        var experiment = {
          id: 1,
          type: 'test_kit',
          started_at: null,
          completed_at: null
        }
        spyOn(this.Status, 'getData').and.returnValue({
          experiment_controller: {
            machine: {
              state: 'running'
            },
            experiment: {}
          }
        })
        spyOn(this.state, 'go')
        this.scope.deleteMode = false
        this.HomeCtrl.openExperiment(experiment)
        expect(this.Status.getData).toHaveBeenCalled()
        expect(this.state.go).toHaveBeenCalledWith('pika_test.setWellsA', {
          id: experiment.id
        })
      })

      it('should go to pika_test.results', function() {
        var experiment = {
          id: 1,
          type: 'test_kit',
          started_at: new Date().toString(),
          completed_at: new Date().toString()
        }
        spyOn(this.Status, 'getData').and.returnValue({
          experiment_controller: {
            machine: {
              state: 'idle'
            },
            experiment: {}
          }
        })
        spyOn(this.state, 'go')
        this.scope.deleteMode = false
        this.HomeCtrl.openExperiment(experiment)
        expect(this.Status.getData).toHaveBeenCalled()
        expect(this.state.go).toHaveBeenCalledWith('pika_test.results', {
          id: experiment.id
        })
      })

      it('should go to pika_test.exp-running', function() {
        var experiment = {
          id: 1,
          type: 'test_kit',
          started_at: new Date().toString(),
          completed_at: null
        }
        spyOn(this.Status, 'getData').and.returnValue({
          experiment_controller: {
            machine: {
              state: 'running'
            },
            experiment: experiment
          }
        })
        spyOn(this.state, 'go')
        this.scope.deleteMode = false
        this.HomeCtrl.openExperiment(experiment)
        expect(this.Status.getData).toHaveBeenCalled()
        expect(this.state.go).toHaveBeenCalledWith('pika_test.exp-running', {
          id: experiment.id
        })
      })

      it('should go to pika_test.exp-running when started isnt null', function() {
        var experiment = {
          id: 1,
          type: 'test_kit',
          started_at: new Date().toString(),
          completed_at: null
        }
        spyOn(this.Status, 'getData').and.returnValue({
          experiment_controller: {
            machine: {
              state: 'idle'
            },
            experiment: {}
          }
        })
        spyOn(this.state, 'go')
        this.scope.deleteMode = false
        this.HomeCtrl.openExperiment(experiment)
        expect(this.Status.getData).toHaveBeenCalled()
        expect(this.state.go).toHaveBeenCalledWith('pika_test.exp-running', {
          id: experiment.id
        })
      })

    })

  })

})();
