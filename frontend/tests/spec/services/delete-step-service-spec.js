describe("Testing deleteStepService", function() {

    var _deleteStepService, _constants, _correctNumberingService, _circleManager, _editModeService;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

        });

        inject(function($injector) {

            _deleteStepService = $injector.get('deleteStepService');
            _constants = $injector.get('constants');
            _correctNumberingService = $injector.get("correctNumberingService");
            _circleManager = $injector.get('circleManager');
            _editModeService = $injector.get('editModeService');
        });
    });

    it("It should test deleteStep method", function() {

        var stage = {
            setNewWidth: function() {},
            deleteAllStepContents: function() {},
            moveAllStepsAndStages: function() {},
            childSteps: [
                {
                    name: 'step1'
                }
            ]
        };

        var currentStep = {
            wireNextAndPreviousStep: function() {},
        };

        $scope = {
            index: 1,
            ordealStatus: 5
        };

        spyOn(_deleteStepService,"configureStepForDelete").and.returnValue(true);
        spyOn(_deleteStepService, "removeWholeStage").and.returnValue(true);
        spyOn(_deleteStepService, "deleteFromArrays").and.returnValue(true);
        spyOn(_deleteStepService, "postDelete").and.returnValue(true);

        spyOn(stage, "setNewWidth");
        spyOn(stage, "deleteAllStepContents");
        spyOn(stage, "moveAllStepsAndStages");

        _deleteStepService.deleteStep(stage, currentStep, $scope);

        expect(_deleteStepService.configureStepForDelete).toHaveBeenCalled();
        expect(_deleteStepService.removeWholeStage).not.toHaveBeenCalled();
        expect(_deleteStepService.deleteFromArrays).toHaveBeenCalled();
        expect(_deleteStepService.postDelete).toHaveBeenCalled();

        expect(stage.setNewWidth).toHaveBeenCalledWith(_constants.stepWidth * -1);
        expect(stage.deleteAllStepContents).toHaveBeenCalled();
        expect(stage.moveAllStepsAndStages).toHaveBeenCalled();

    });

    it("It should test deleteStep method when stage has no step", function() {

        var stage = {
            setNewWidth: function() {},
            deleteAllStepContents: function() {},
            moveAllStepsAndStages: function() {},
            childSteps: [
            ]
        };

        var currentStep = {
            wireNextAndPreviousStep: function() {},
        };

        $scope = {
            index: 1,
            ordealStatus: 5
        };

        spyOn(_deleteStepService,"configureStepForDelete").and.returnValue(true);
        spyOn(_deleteStepService, "removeWholeStage").and.returnValue(true);
        spyOn(_deleteStepService, "deleteFromArrays").and.returnValue(true);
        spyOn(_deleteStepService, "postDelete").and.returnValue(true);

        _deleteStepService.deleteStep(stage, currentStep, $scope);

        expect(_deleteStepService.removeWholeStage).toHaveBeenCalled();
        expect(_deleteStepService.configureStepForDelete).not.toHaveBeenCalled();
    });

    it("It should test deleteFromArrays method", function() {

        var start = 10;
        var ordealStatus = 13;
        var stage = {
            parent: {
                allStepViews: {
                    splice: function() {}
                }
            },
            childSteps: {
                splice: function() {}
            },
            model: {
                steps: {
                    splice: function() {}
                }
            }
        };

        spyOn(stage.parent.allStepViews, "splice");
        spyOn(stage.childSteps, "splice");
        spyOn(stage.model.steps, "splice");

        _deleteStepService.deleteFromArrays(stage, start, ordealStatus);

        expect(stage.parent.allStepViews.splice).toHaveBeenCalledWith(ordealStatus - 1, 1);
        expect(stage.childSteps.splice).toHaveBeenCalledWith(start, 1);
        expect(stage.model.steps.splice).toHaveBeenCalledWith(start, 1);
    });

    it("It should test configureStepForDelete", function() {
        
        var indexVal = 10;
        var thisStep = {
            configureStepName: function() {},
            moveStep: function() {},
            index: indexVal,
        };

        var stage = {
            childSteps: {
                slice: function() {
                    return [
                        thisStep
                    ];
                }
            }
        };

        spyOn(thisStep, "configureStepName");
        spyOn(thisStep, "moveStep");
        
        _deleteStepService.configureStepForDelete(stage, 1);

        expect(thisStep.configureStepName).toHaveBeenCalled();
        expect(thisStep.moveStep).toHaveBeenCalledWith(-1, true);
        expect(thisStep.index).toEqual(indexVal - 1);
    });

    it("It should test removeWholeStage method", function() {

        var stage = {
            deleteStageContents: function() {},
            wireStageNextAndPrevious: function() {},
            nextStage: {
                childSteps: [
                    {
                        index: 0,
                        parentStage: {
                            updateStageData: function() {}
                        }
                    }
                ]
            },
            parent: {
                allStageViews: {
                    splice: function() {}
                }
            }
        };

        spyOn(stage, "deleteStageContents");
        spyOn(stage, "wireStageNextAndPrevious");
        spyOn(stage.parent.allStageViews, "splice");
        spyOn(stage.nextStage.childSteps[0].parentStage, "updateStageData");

        _deleteStepService.removeWholeStage(stage);

        expect(stage.deleteStageContents).toHaveBeenCalled();
        expect(stage.wireStageNextAndPrevious).toHaveBeenCalled();
        expect(stage.parent.allStageViews.splice).toHaveBeenCalled();
        expect(stage.nextStage.childSteps[0].parentStage.updateStageData).toHaveBeenCalled();
    });

    it("It should test removeWholeStage method, when stage has previous stage", function() {

        var stage = {
            deleteStageContents: function() {},
            wireStageNextAndPrevious: function() {},
            previousStage: {
                childSteps: [
                    {
                        parentStage: {
                            updateStageData: function() {}
                        }
                    }
                ]
            },
            parent: {
                allStageViews: {
                    splice: function() {}
                }
            }
        };

        spyOn(stage, "deleteStageContents");
        spyOn(stage, "wireStageNextAndPrevious");
        spyOn(stage.parent.allStageViews, "splice");
        spyOn(stage.previousStage.childSteps[0].parentStage, "updateStageData");

        _deleteStepService.removeWholeStage(stage);

        expect(stage.deleteStageContents).toHaveBeenCalled();
        expect(stage.wireStageNextAndPrevious).toHaveBeenCalled();
        expect(stage.parent.allStageViews.splice).toHaveBeenCalled();
        expect(stage.previousStage.childSteps[0].parentStage.updateStageData).toHaveBeenCalled();
    });


    it("It should test postDelete method", function() {

        var stage = {
            stageHeader: function() {},
            parent: {
                setDefaultWidthHeight: function() {},
                allStepViews: [
                    { index: 1},
                    { index: 2}
                ]
            }
        };

        var selected = {
            circle: {
                manageClick: function() {}
            }
        };

        var $scope = {
            applyValues: function() {}
        };

        spyOn(stage, 'stageHeader');
        spyOn(stage.parent, "setDefaultWidthHeight");

        spyOn(selected.circle, "manageClick");

        spyOn($scope, "applyValues");

        spyOn(_correctNumberingService, "correctNumbering").and.returnValue(true);
        spyOn(_deleteStepService, "makeSureLastStepHasNoCurve").and.returnValue(true);
        spyOn(_deleteStepService, "getAnotherSelection").and.returnValue(true);
        spyOn(_editModeService, "editStageMode").and.returnValue(true);
        spyOn(_circleManager, "addRampLines").and.returnValue(true);
        
        _deleteStepService.postDelete(stage, $scope, selected);

        expect(_correctNumberingService.correctNumbering).toHaveBeenCalled();
        expect(_deleteStepService.makeSureLastStepHasNoCurve).toHaveBeenCalled();
        expect(_circleManager.addRampLines).toHaveBeenCalled();
        expect(stage.stageHeader).toHaveBeenCalled();

        expect($scope.applyValues).toHaveBeenCalled();
        expect(selected.circle.manageClick).toHaveBeenCalled();
        
        expect(_deleteStepService.getAnotherSelection).not.toHaveBeenCalled();
        expect(_editModeService.editStageMode).not.toHaveBeenCalled();

        expect(stage.parent.setDefaultWidthHeight).toHaveBeenCalled();
    });

    it("It should test postDelete method when it has no selected and allStepViews.length === 1", function() {

        var stage = {
            stageHeader: function() {},
            parent: {
                setDefaultWidthHeight: function() {},
                allStepViews: [
                    { index: 1},
                ]
            }
        };

        var selected = null;

        var $scope = {
            applyValues: function() {}
        };

        spyOn(stage, 'stageHeader');
        spyOn(stage.parent, "setDefaultWidthHeight");

        spyOn($scope, "applyValues");

        spyOn(_correctNumberingService, "correctNumbering").and.returnValue(true);
        spyOn(_deleteStepService, "makeSureLastStepHasNoCurve").and.returnValue(true);
        spyOn(_deleteStepService, "getAnotherSelection").and.returnValue({
            circle: {
                manageClick: function() {}
            }
        });
        spyOn(_editModeService, "editStageMode").and.returnValue(true);
        spyOn(_circleManager, "addRampLines").and.returnValue(true);
        
        _deleteStepService.postDelete(stage, $scope, selected);

        expect(_correctNumberingService.correctNumbering).toHaveBeenCalled();
        expect(_deleteStepService.makeSureLastStepHasNoCurve).toHaveBeenCalled();
        expect(_circleManager.addRampLines).toHaveBeenCalled();
        expect(stage.stageHeader).toHaveBeenCalled();

        expect($scope.applyValues).toHaveBeenCalled();
        
        expect(_deleteStepService.getAnotherSelection).toHaveBeenCalled();
        expect(_editModeService.editStageMode).toHaveBeenCalled();

        expect(stage.parent.setDefaultWidthHeight).toHaveBeenCalled();
    
    });

    it("It should test makeSureLastStepHasNoCurve", function() {

        var stage = {
            parent: {
                canvas: {
                    remove: function() {},
                },
                allStepViews: [
                    {   index: 1, 
                        circle: {
                            curve: {

                            }
                        }
                    },
                    { 
                        index: 2,
                        circle: {
                            curve: {

                            }
                        }
                        
                    }
                ]
            }
        };

        spyOn(stage.parent.canvas, "remove");

        _deleteStepService.makeSureLastStepHasNoCurve(stage);

        expect(stage.parent.canvas.remove).toHaveBeenCalled();
    });

    it("It should test getAnotherSelection method, if stage has previousStage", function() {

        var stage = {
            previousStage: {
                childSteps: [
                    { index: 1 },
                    { index: 100 }
                ]
            }
        };

        var selection = _deleteStepService.getAnotherSelection(stage);

        expect(selection.index).toEqual(100);
    });

    it("It should test getAnotherSelection method, if stage has no previousStage", function() {

        var stage = {
            nextStage: {
                childSteps: [
                    { index: 1 },
                    { index: 100 }
                ]
            }
        };

        var selection = _deleteStepService.getAnotherSelection(stage);

        expect(selection.index).toEqual(1);
    });
});