describe("Testing stepTemperatureService", function() {

    var _editMode, _ExperimentLoader, _moveRampLineService, _stepTemperatureService;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            //$provide.value('Experiment',  meth);
        });

        inject(function($injector) {

            _editMode = $injector.get('editMode');
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _moveRampLineService = $injector.get("moveRampLineService");
            _stepTemperatureService = $injector.get("stepTemperatureService");
        });
    });

    it("It should test postEdit method", function() {

        var $scope = {
            step: {
                id: 10,
                temperature: 67
            }
        };

        var parent = {
            
            getTop: function() {
                return {
                    top: 20
                };
            },
            canvas: {
                renderAll: function() {}
            },
            model: {
                temperature: 30
            },
            circleGroup: {
                top: 20,
                setCoords: function() {},
            },
            createNewStepDataGroup: function() {},

        };

        var textObj = {
            text: "text"
        };
        _ExperimentLoader.changeTemperature = function(d) {
            return {
                then: function(callback1) {
                    callback1();
                }
            };
        };
        spyOn(_moveRampLineService, "manageDrag").and.returnValue(true);
        spyOn(_ExperimentLoader, "changeTemperature").and.callThrough();
        _stepTemperatureService.postEdit($scope, parent, textObj);

        expect(_editMode.tempActive).toEqual(false);
        expect(_editMode.currentActiveTemp).toEqual(null);
        expect(parent.model.temperature).toEqual($scope.step.temperature);
        expect(parent.circleGroup.top).toEqual(20);
        expect(_moveRampLineService.manageDrag).toHaveBeenCalled();
        expect(_ExperimentLoader.changeTemperature).toHaveBeenCalled();
    });

    it("It should test postEdit method, when temperature is zero", function() {

        var $scope = {
            step: {
                id: 10,
                temperature: 0
            }
        };

        var parent = {
            
            getTop: function() {
                return {
                    top: 20
                };
            },
            canvas: {
                renderAll: function() {}
            },
            model: {
                temperature: 30
            },
            circleGroup: {
                top: 20,
                setCoords: function() {},
            },
            createNewStepDataGroup: function() {},

        };

        var textObj = {
            text: "0"
        };
        _ExperimentLoader.changeTemperature = function(d) {
            return {
                then: function(callback1) {
                    callback1();
                }
            };
        };
        spyOn(_moveRampLineService, "manageDrag").and.returnValue(true);
        spyOn(_ExperimentLoader, "changeTemperature").and.callThrough();
        _stepTemperatureService.postEdit($scope, parent, textObj);

        expect(_editMode.tempActive).toEqual(false);
        expect(_editMode.currentActiveTemp).toEqual(null);
        expect(parent.model.temperature).toEqual($scope.step.temperature);
        expect(parent.circleGroup.top).toEqual(20);
        expect(_moveRampLineService.manageDrag).toHaveBeenCalled();
        expect(_ExperimentLoader.changeTemperature).toHaveBeenCalled();
    });

    it("It should test postEdit method, when temperature is more than 100", function() {

        var $scope = {
            step: {
                id: 10,
                temperature: 1000
            }
        };

        var parent = {
            
            getTop: function() {
                return {
                    top: 20
                };
            },
            canvas: {
                renderAll: function() {}
            },
            model: {
                temperature: 30
            },
            circleGroup: {
                top: 20,
                setCoords: function() {},
            },
            createNewStepDataGroup: function() {},

        };

        var textObj = {
            text: "1110"
        };
        _ExperimentLoader.changeTemperature = function(d) {
            return {
                then: function(callback1) {
                    callback1();
                }
            };
        };
        spyOn(_moveRampLineService, "manageDrag").and.returnValue(true);
        spyOn(_ExperimentLoader, "changeTemperature").and.callThrough();
        _stepTemperatureService.postEdit($scope, parent, textObj);

        expect(_editMode.tempActive).toEqual(false);
        expect(_editMode.currentActiveTemp).toEqual(null);
        expect(parent.model.temperature).toEqual(100);
        expect(parent.circleGroup.top).toEqual(20);
        expect(_moveRampLineService.manageDrag).toHaveBeenCalled();
        expect(_ExperimentLoader.changeTemperature).toHaveBeenCalled();
    });
});