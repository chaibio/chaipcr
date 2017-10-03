describe("Testing stepHoldTimeService", function() {

    var _TimeService, _stepHoldTimeService, _editMode, _ExperimentLoader, _alerts, $httpBackend;
    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

        });

        inject(function($injector) {

            _stepHoldTimeService = $injector.get('stepHoldTimeService');
            _editMode = $injector.get('editMode');
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _TimeService = $injector.get('TimeService');
            _alerts = $injector.get('alerts');
            $httpBackend = $injector.get('$httpBackend');
        });
    });

    it("It should test formatHoldTime method", function() {

        spyOn(_TimeService, "newTimeFormatting").and.returnValue(true);
        var hold_time = 100;
        var retVal = _stepHoldTimeService.formatHoldTime(hold_time);
        expect(_TimeService.newTimeFormatting).toHaveBeenCalled();
        expect(retVal).toEqual(true);
    });

    it("It should test ifLastStep method", function() {

        var step = {
            parentStage: {
                nextStage: null
            },
            nextStep: null
        };

        var retVal = _stepHoldTimeService.ifLastStep(step);
        expect(retVal).toEqual(true);
    });

    it("It should test postEdit method", function() {

        var $scope = {
            step: {
                hold_time: 10
            }
        };

        var parent = {
            createNewStepDataGroup: function() {},
            canvas: {
                    renderAll: function() {},
                },
            model: {
            }
        };

        var textObject = {

            text: 11
        };

        spyOn(_TimeService, "convertToSeconds").and.returnValue(20);
        spyOn(_stepHoldTimeService, "saveHoldTime").and.returnValue();
        spyOn(parent, "createNewStepDataGroup").and.returnValue(true);
        spyOn(parent.canvas, "renderAll");

        _stepHoldTimeService.postEdit($scope, parent, textObject);

        expect(parent.model.hold_time).toEqual(20);
        expect(_stepHoldTimeService.saveHoldTime).toHaveBeenCalled();
        expect(parent.createNewStepDataGroup).toHaveBeenCalled();
        expect(parent.canvas.renderAll).toHaveBeenCalled();
    });


    it("It should test postEdit method, when negative value is returned from convertToSeconds", function() {

        var $scope = {
            step: {
                hold_time: 10
            }
        };

        var parent = {
            createNewStepDataGroup: function() {},
            canvas: {
                    renderAll: function() {},
                },
            model: {
            }
        };

        var textObject = {

            text: 11
        };

        spyOn(_TimeService, "convertToSeconds").and.returnValue(-20);
        spyOn(_alerts, "showMessage").and.returnValue(true);
        spyOn(_stepHoldTimeService, "saveHoldTime").and.returnValue();
        spyOn(parent, "createNewStepDataGroup").and.returnValue(true);
        spyOn(parent.canvas, "renderAll");

        _stepHoldTimeService.postEdit($scope, parent, textObject);

        expect(parent.model.hold_time).toEqual(10);
        expect(_alerts.showMessage).toHaveBeenCalled();
        expect(_stepHoldTimeService.saveHoldTime).not.toHaveBeenCalled();
        expect(parent.createNewStepDataGroup).toHaveBeenCalled();
        expect(parent.canvas.renderAll).toHaveBeenCalled();
    });

    it("It should test postEdit method, when 0 is returned from convertToSeconds", function() {

        var $scope = {
            step: {
                hold_time: 10
            }
        };

        var parent = {
            createNewStepDataGroup: function() {},
            canvas: {
                    renderAll: function() {},
                },
            model: {
            }
        };

        var textObject = {

            text: 11
        };

        spyOn(_TimeService, "convertToSeconds").and.returnValue(0);
        spyOn(_alerts, "showMessage").and.returnValue(true);
        spyOn(_stepHoldTimeService, "manageZeroHoldTime").and.returnValue(true);
        spyOn(_stepHoldTimeService, "saveHoldTime").and.returnValue();
        spyOn(parent, "createNewStepDataGroup").and.returnValue(true);
        spyOn(parent.canvas, "renderAll");

        _stepHoldTimeService.postEdit($scope, parent, textObject);

        expect(parent.model.hold_time).toEqual(10);
        expect(_alerts.showMessage).not.toHaveBeenCalled();
        expect(_stepHoldTimeService.saveHoldTime).not.toHaveBeenCalled();
        expect(_stepHoldTimeService.manageZeroHoldTime).toHaveBeenCalled();
        expect(parent.createNewStepDataGroup).toHaveBeenCalled();
        expect(parent.canvas.renderAll).toHaveBeenCalled();
    });

    it("It should test manageZeroHoldTime method", function() {

        var $scope = {
            step: {
                collect_data: false
            }
        };
        var parent = {
            doThingsForLast: function() {},
            parent: {

            }
        };
        var newHoldTime = 12;
        var previousHoldTime = 15;

        spyOn(_stepHoldTimeService, "ifLastStep").and.returnValue(true);
        spyOn(_stepHoldTimeService, "saveHoldTime").and.returnValue(true);

        _stepHoldTimeService.manageZeroHoldTime($scope, parent, newHoldTime, previousHoldTime);

        expect(_stepHoldTimeService.ifLastStep).toHaveBeenCalled();
        expect(_stepHoldTimeService.saveHoldTime).toHaveBeenCalled();
        expect($scope.step.hold_time).toEqual(newHoldTime);
    });

    it("It should test manageZeroHoldTime method, when the selected step is not the last step", function() {

        var $scope = {
            step: {
                collect_data: false
            }
        };
        var parent = {
            doThingsForLast: function() {},
            parent: {

            }
        };
        var newHoldTime = 12;
        var previousHoldTime = 15;

        spyOn(_stepHoldTimeService, "ifLastStep").and.returnValue(false);
        spyOn(_stepHoldTimeService, "saveHoldTime").and.returnValue(true);
        spyOn(_alerts, "showMessage").and.returnValue(true);
        _stepHoldTimeService.manageZeroHoldTime($scope, parent, newHoldTime, previousHoldTime);

        expect(_stepHoldTimeService.ifLastStep).toHaveBeenCalled();
        expect(_stepHoldTimeService.saveHoldTime).not.toHaveBeenCalled();
        expect(_alerts.showMessage).toHaveBeenCalled();
        //expect($scope.step.hold_time).toEqual(newHoldTime);
    });

    it("It should test saveHoldTime method", function() {
        var $scope = {
            step: {
                collect_data: false
            }
        };
        
        spyOn(_ExperimentLoader, "changeHoldDuration").and.returnValue({
            then: function(callBack) {
                callBack();
            }
        });
        _stepHoldTimeService.saveHoldTime($scope);
        expect(_ExperimentLoader.changeHoldDuration).toHaveBeenCalled();
    });
});