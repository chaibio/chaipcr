describe("Testing StageStepCtrl", function() {

    var _StageStepCtrl, _$scope, _ExperimentLoader, _canvas, _$uibModal, _alerts, _expName, _$rootScope, _$window, _$controller;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            //_$stateParams = $injector.get('$stateParams');
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _canvas = $injector.get('canvas');
            _$uibModal = $injector.get('$uibModal');
            _alerts = $injector.get('alerts');
            _expName = $injector.get('expName');
            _alerts = $injector.get('alerts');
            _$window = $injector.get('$window');
            _$controller = $injector.get('$controller');
            
            _StageStepCtrl = _$controller('StageStepCtrl', {
                $scope: _$scope
            });
        });
    });

    it("It should test init values", function() {
        expect(_$scope.stage).toEqual(jasmine.any(Object));
        expect(_$scope.step).toEqual(jasmine.any(Object));
        expect(_$scope.exp_completed).toEqual(false);
        //expect(1).toEqual(2);
    });

    it("It should test expName:Updated event", function() {

        _expName.name = "Chai";

        _$scope.protocol = {};

        _$scope.$broadcast("expName:Updated");

        expect(_$scope.protocol.name).toEqual(_expName.name);
    });

    it("It should test event:error-server event", function() {

        _alerts.showMessage = function() {

        };

        spyOn(_alerts, "showMessage");

        _$rootScope.$broadcast("event:error-server");

        expect(_alerts.showMessage).toHaveBeenCalled();
    });

    it("It should test alerts.nonDigit", function() {

        _alerts.showMessage = function() {

        };

        spyOn(_alerts, "showMessage");

        _$rootScope.$broadcast("alerts.nonDigit");

        expect(_alerts.showMessage).toHaveBeenCalled();
    });

    it("It should test initiate method", function() {

        _ExperimentLoader.getExperiment = function() {
            return {
                then: function(callback) {
                    var data = {
                        experiment: {
                            started_at: "20-02-2018"
                        }
                    };
                    callback(data);
                }
            };
        };

        _ExperimentLoader.loadFirstStages = function() {
            return {
                name: "Stage1"
            };
        };

        _ExperimentLoader.loadFirstStep = function() {
            return {
                name: "Step1"
            };
        };

        spyOn(_ExperimentLoader, "getExperiment").and.callThrough();
        spyOn(_ExperimentLoader, "loadFirstStages").and.callThrough();
        spyOn(_ExperimentLoader, "loadFirstStep").and.callThrough();
        spyOn(_$scope, "$broadcast");
        spyOn(_canvas, "init");

        _$scope.initiate();

        expect(_ExperimentLoader.getExperiment).toHaveBeenCalled();
        expect(_ExperimentLoader.loadFirstStages).toHaveBeenCalled();
        expect(_ExperimentLoader.loadFirstStep).toHaveBeenCalled();
        expect(_$scope.$broadcast).toHaveBeenCalled();
        expect(_canvas.init).toHaveBeenCalled();

        expect(_$scope.protocol.started_at).toEqual("20-02-2018");
        console.log(_$scope.stage);
        expect(_$scope.stage.name).toEqual("Stage1");
        expect(_$scope.step.name).toEqual("Step1");
        expect(_$scope.summaryMode).toEqual(false);
        expect(_$scope.editStageMode).toEqual(false);
        expect(_$scope.showScrollbar).toEqual(false);
        expect(_$scope.scrollWidth).toEqual(0);
        expect(_$scope.scrollLeft).toEqual(0);
        expect(_$scope.exp_completed).toEqual(true);
    });

    it("It should test initiate method, when started at null", function() {

        _ExperimentLoader.getExperiment = function() {
            return {
                then: function(callback) {
                    var data = {
                        experiment: {
                            started_at: null
                        }
                    };
                    callback(data);
                }
            };
        };

        _ExperimentLoader.loadFirstStages = function() {
            return {
                name: "Stage1"
            };
        };

        _ExperimentLoader.loadFirstStep = function() {
            return {
                name: "Step1"
            };
        };

        spyOn(_ExperimentLoader, "getExperiment").and.callThrough();
        spyOn(_ExperimentLoader, "loadFirstStages").and.callThrough();
        spyOn(_ExperimentLoader, "loadFirstStep").and.callThrough();
        spyOn(_$scope, "$broadcast");
        spyOn(_canvas, "init");

        _$scope.initiate();

        expect(_ExperimentLoader.getExperiment).toHaveBeenCalled();
        expect(_ExperimentLoader.loadFirstStages).toHaveBeenCalled();
        expect(_ExperimentLoader.loadFirstStep).toHaveBeenCalled();
        expect(_$scope.$broadcast).toHaveBeenCalled();
        expect(_canvas.init).toHaveBeenCalled();
        expect(_$scope.stage.name).toEqual("Stage1");
        expect(_$scope.step.name).toEqual("Step1");
        expect(_$scope.summaryMode).toEqual(false);
        expect(_$scope.editStageMode).toEqual(false);
        expect(_$scope.showScrollbar).toEqual(false);
        expect(_$scope.scrollWidth).toEqual(0);
        expect(_$scope.scrollLeft).toEqual(0);
        expect(_$scope.exp_completed).toEqual(false);
    });

    it("It should test applyValuesFromOutSide method", function() {

        var circle = {

            parent: {
                name: "fabricStep",
                model: {
                    name: "Step10"
                },
                parentStage: {
                    model: {
                        name: "Stage1"
                    }
                },

            }
        };
        _$scope.$apply = function(callback) {

            callback();
        };

        _$scope.applyValuesFromOutSide(circle);

        expect(_$scope.step.name).toEqual("Step10");
        expect(_$scope.stage.name).toEqual("Stage1");
        expect(_$scope.fabricStep.name).toEqual("fabricStep");
    });

    it("It should test applyValues method", function() {
        
        var circle = {

            parent: {
                name: "fabricStep",
                model: {
                    name: "Step10"
                },
                parentStage: {
                    model: {
                        name: "Stage1"
                    }
                },

            }
        };

        _$scope.applyValues(circle);

        expect(_$scope.step.name).toEqual("Step10");
        expect(_$scope.stage.name).toEqual("Stage1");
        expect(_$scope.fabricStep.name).toEqual("fabricStep");
    });

    

});