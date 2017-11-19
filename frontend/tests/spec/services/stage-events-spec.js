describe("Testing stageEvents service", function() {

    var $scope, C, canvas, _stepGraphics, stageEvents;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _stepGraphics = $injector.get('stepGraphics');
            
            stageEvents = $injector.get('stageEvents');
            
            $scope = {
                $watch: function(arg1, callback) {
                    //callback();
                }
            };

            canvas = {
                renderAll: function() {}
            };

            C = {

            }; 

        });
    });

    it("It should test init method", function() {

        spyOn($scope, "$watch").and.returnValue(true);
        stageEvents.init($scope, canvas, C);
        expect($scope.$watch).toHaveBeenCalledTimes(3);
    });

    it("It should test changeDeltaText method", function() {

        $scope.fabricStep = {
            parentStage: {
                childSteps: [
                    {
                        index: 0
                    },
                    {
                        index: 1
                    },
                ],
                parent: {
                    editStageStatus: false
                }, 
                model: {
                    stage_type: "cycling"
                }
            }
        };

        _stepGraphics.autoDeltaDetails = function() {};

        spyOn(_stepGraphics, "autoDeltaDetails").and.returnValue(true);

        stageEvents.changeDeltaText($scope, C);

        expect(_stepGraphics.autoDeltaDetails).toHaveBeenCalledTimes(2);
    });

    it("It should test changeDeltaText method when editStageStatus = true", function() {

        $scope.fabricStep = {
            parentStage: {
                childSteps: [
                    {
                        index: 0
                    },
                    {
                        index: 1
                    },
                ],
                parent: {
                    editStageStatus: true
                }, 
                model: {
                    stage_type: "cycling"
                }
            }
        };

        _stepGraphics.autoDeltaDetails = function() {};

        spyOn(_stepGraphics, "autoDeltaDetails").and.returnValue(true);

        stageEvents.changeDeltaText($scope, C);

        expect(_stepGraphics.autoDeltaDetails).not.toHaveBeenCalledTimes(2);
    });

    it("It should test numCyclesChange method", function() {

        $scope.fabricStep = {
            parentStage: {
                stageHeader: function() {},
                childSteps: [
                    {
                        index: 0
                    },
                    {
                        index: 1
                    },
                ],
                parent: {
                    editStageStatus: true
                }, 
                model: {
                    stage_type: "cycling"
                }
            }
        };

        spyOn($scope.fabricStep.parentStage, "stageHeader");
        spyOn(canvas, "renderAll");

        stageEvents.init($scope, canvas, C);
        stageEvents.numCyclesChange();

        expect($scope.fabricStep.parentStage.stageHeader).toHaveBeenCalled();
        expect(canvas.renderAll).toHaveBeenCalled();
    });

    it("It should test autoDeltaChange method", function() {

        $scope.fabricStep = {
            parentStage: {
                stageHeader: function() {},
                childSteps: [
                    {
                        index: 0
                    },
                    {
                        index: 1
                    },
                ],
                parent: {
                    editStageStatus: true
                }, 
                model: {
                    stage_type: "cycling"
                }
            }
        };

        spyOn(stageEvents, "changeDeltaText").and.returnValue(true);
        spyOn(canvas, "renderAll");

        stageEvents.init($scope, canvas, C);
        stageEvents.autoDeltaChange();

        expect(stageEvents.changeDeltaText).toHaveBeenCalled();
        expect(canvas.renderAll).toHaveBeenCalled();

    });

    it("It should test autoDeltaStartCyclesChange method", function() {

        $scope.fabricStep = {
            parentStage: {
                stageHeader: function() {},
                childSteps: [
                    {
                        index: 0
                    },
                    {
                        index: 1
                    },
                ],
                parent: {
                    editStageStatus: true
                }, 
                model: {
                    stage_type: "cycling"
                }
            }
        };

        spyOn(stageEvents, "changeDeltaText").and.returnValue(true);
        spyOn(canvas, "renderAll");

        stageEvents.init($scope, canvas, C);
        stageEvents.autoDeltaStartCyclesChange();

        expect(stageEvents.changeDeltaText).toHaveBeenCalled();
        expect(canvas.renderAll).toHaveBeenCalled();
    });
});