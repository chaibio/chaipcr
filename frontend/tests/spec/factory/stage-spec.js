describe("Testing stage factory", function() {

    var stage, _stage,  _step, _previouslySelected, _stageGraphics, _constants, _correctNumberingService, 
    _addStepService, _deleteStepService, _moveStageToSides;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            $provide.value('IsTouchScreen', function () {});

            $provide.value('step', function() {
                return {
                    stepStatus: "newly created"
                };
            });
        });

        inject(function($injector) {

            _step = $injector.get('step');
            _stage = $injector.get('stage');
            _previouslySelected = $injector.get('previouslySelected');
            _stageGraphics = $injector.get('stageGraphics');
            _constants = $injector.get('constants');
            _correctNumberingService = $injector.get('correctNumberingService');
            _addStepService = $injector.get('addStepService');
            _deleteStepService = $injector.get('deleteStepService');
            _moveStageToSides = $injector.get('moveStageToSides');  
        });

        var model = {
            steps: [
                {

                },
                {

                }
            ]
        };

        var kanvas = {
            name: "ChaiKanvas",
            canvas: {
                renderAll: function() {},
                remove: function() {},
                discardActiveGroup: function() {}
            }
        };

        var index = 1;

        var insert = false;

        $scope = {

        };

        stage = new _stage(model, kanvas, index, insert, $scope);

    });

    it("It should test initial values of stage", function() {

        expect(stage.model.steps.length).toEqual(2);
        expect(stage.index).toEqual(1);
        expect(stage.canvas.renderAll).toEqual(jasmine.any(Function));
        expect(stage.myWidth).toEqual(258);
        expect(stage.parent.name).toEqual("ChaiKanvas");
        expect(stage.childSteps).toEqual(jasmine.any(Array));
        expect(stage.nextStage).toEqual(null);
        expect(stage.previousStage).toEqual(null);
        expect(stage.noOfCycles).toEqual(null);
        expect(stage.insertMode).toEqual(false);
        expect(stage.shrinked).toEqual(false);
        expect(stage.shadowText).toEqual("0px 1px 2px rgba(0, 0, 0, 0.5)");
        expect(stage.visualComponents).toEqual(jasmine.any(Object));
        expect(stage.stageMovedDirection).toEqual(null);
        expect(stage.shortStageName).toEqual(false);
        expect(stage.shrinkedStage).toEqual(false);
        expect(stage.sourceStage).toEqual(false);
        expect(stage.moveStepAction).toEqual(null);
    });

    it("It should test setNewWidth method", function() {
        
        stage.myWidth = 100;
        var add = 50;
        spyOn(stage, "setWidth").and.returnValue(true);
        stage.setNewWidth(50);
        expect(stage.myWidth).toEqual(150);
        expect(stage.setWidth).toHaveBeenCalled();
    });

    it("It should test updateWidth method", function() {

        spyOn(stage, "setWidth").and.returnValue(true);

        stage.updateWidth();

        expect(stage.setWidth).toHaveBeenCalled();
        expect(stage.myWidth).toEqual(258);
    });

    it("It should test setWidth method", function() {

        stage.stageRect = {
            setWidth: function() {},
            setCoords: function() {}
        };

        stage.roof = {
            setWidth: function() {}
        };

        stage.myWidth = 130;

        spyOn(stage.stageRect, "setWidth");
        spyOn(stage.stageRect, "setCoords");
        spyOn(stage.roof, "setWidth");

        stage.setWidth();

        expect(stage.stageRect.setWidth).toHaveBeenCalledWith(stage.myWidth);
        expect(stage.stageRect.setCoords).toHaveBeenCalled();
        expect(stage.roof.setWidth).toHaveBeenCalledWith(stage.myWidth);
    });

    it("It should test collapseStage method", function() {

        spyOn(stage, "deleteAllStepContents").and.returnValue(true);
        spyOn(stage, "deleteStageContents").and.returnValue(true);
        stage.nextStage = null;

        stage.childSteps = [
            {
                id: 1
            },
            {
                id: 2
            }
        ];
        stage.collapseStage();

        expect(stage.deleteAllStepContents).toHaveBeenCalledTimes(2);
        expect(stage.deleteStageContents).toHaveBeenCalled();

    });

    it("It should test collapseStage method, when stage has nextStage", function() {

        spyOn(stage, "deleteAllStepContents").and.returnValue(true);
        spyOn(stage, "deleteStageContents").and.returnValue(true);
        spyOn(stage, "moveAllStepsAndStages").and.returnValue(true);

        stage.nextStage = null;

        stage.childSteps = [
            {
                id: 1
            },
            {
                id: 2
            }
        ];

        stage.nextStage = {


        };
        stage.collapseStage();

        expect(stage.deleteAllStepContents).toHaveBeenCalledTimes(2);
        expect(stage.deleteStageContents).toHaveBeenCalled();
        expect(stage.moveAllStepsAndStages).toHaveBeenCalled();
    });

    it("It should test addNewStep method", function() {

        spyOn(_addStepService, "addNewStep").and.returnValue(true);

        stage.addNewStep();

        expect(_addStepService.addNewStep).toHaveBeenCalled();
    });

    it("It should test deleteStep method", function() {

        spyOn(_deleteStepService, "deleteStep").and.returnValue(true);

        stage.deleteStep();

        expect(_deleteStepService.deleteStep).toHaveBeenCalled();
    });

    describe("Testing different scenarios when we wireStageNextAndPrevious", function() {
        
        it("When stage has precious stage but no netStage", function() {

            stage.previousStage = {

            };

            stage.wireStageNextAndPrevious();
            
            expect(stage.previousStage.nextStage).toEqual(null);
        });

        it("When stage has previousStage nextStage", function() {
            stage.previousStage = {

            };

            stage.nextStage = {
                index: "infinity"
            };

            stage.wireStageNextAndPrevious();

            expect(stage.previousStage.nextStage.index).toEqual("infinity");
        });

        it("When the stage has no previousStage", function() {

            stage.nextStage = {

            };

            stage.wireStageNextAndPrevious();

            expect(stage.nextStage.previousStage).toEqual(null);
        });

        it("When stage has nextStage", function() {

            stage.nextStage = {

            };

            stage.wireStageNextAndPrevious();

            expect(stage.nextStage.previousStage).toEqual(null);
        });

        it("When stage has nextStage and previousStage", function() {

            stage.nextStage = {

            };

            stage.previousStage = {
                comment: "I am previous"
            };

            stage.wireStageNextAndPrevious();

            expect(stage.nextStage.previousStage.comment).toEqual("I am previous");
        });

        it("When stage has no nextStage", function() {

            stage.previousStage = {

            };

            stage.wireStageNextAndPrevious();

            expect(stage.previousStage.nextStage).toEqual(null);
        });
    });

    it("It should test deleteStageContents method", function() {

        stage.visualComponents = {
            roof: {

            },
            step: {

            }
        };

        spyOn(stage.canvas, "remove").and.returnValue(true);
        stage.deleteStageContents();
        expect(stage.canvas.remove).toHaveBeenCalled();
    });

    it("It should test deleteStageContents method when we have 'dots in the components", function() {

        stage.dots = {
            
            forEachObject: function(callback, context) {
                var x = 10;
                callback.call(context, x);
            },
            removeWithUpdate: function() {}
        };

        stage.visualComponents = {
            roof: {},
            step: {},
            dots: stage.dots
        };

        spyOn(stage.dots, "forEachObject").and.callThrough();
        spyOn(stage.dots, "removeWithUpdate");
        spyOn(stage.canvas, "remove");
        spyOn(stage.canvas, "discardActiveGroup");
        
        stage.deleteStageContents();

        expect(stage.dots.forEachObject).toHaveBeenCalled();
        expect(stage.canvas.remove).toHaveBeenCalled();
        expect(stage.dots.removeWithUpdate).toHaveBeenCalled();
        expect(stage.canvas.discardActiveGroup).toHaveBeenCalled();
    });
    
    it("It should test deleteFromStage method", function() {

        var index = 0;
        var ordealStatus = 1;

        stage.childSteps = [
            {
                index: 0,
                wireNextAndPreviousStep: function() {}
            },
            {
                index: 1,

            }
        ];

        stage.parent.allStepViews = {
            splice: function() {}
        };

        stage.model.steps = {
            splice: function() {}
        };

        spyOn(stage, "deleteAllStepContents").and.returnValue(true);
        spyOn(_correctNumberingService, "correctNumbering").and.returnValue(true);
        spyOn(stage.model.steps, "splice");
        spyOn(stage.parent.allStepViews, "splice");

        stage.deleteFromStage(index, ordealStatus);

        expect(stage.deleteAllStepContents).toHaveBeenCalled();
        expect(stage.model.steps.splice).toHaveBeenCalled();
        expect(stage.parent.allStepViews.splice).toHaveBeenCalled();

    });

    it("It should test deleteAllStepContents method", function() {


        var currentStep = {
            deleteAllStepContents: function() {}
        };

        spyOn(currentStep, "deleteAllStepContents");

        stage.deleteAllStepContents(currentStep);

        expect(currentStep.deleteAllStepContents).toHaveBeenCalled();
    });

    it("it should moveIndividualStageAndContents method, when del = true", function() {

        stage.stageGroup = {
            setLeft: function() {},
            setCoords: function() {}
        };

        stage.dots = {
            setLeft: function() {},
            setCoords: function() {}
        };

        stage.childSteps = [
            { id: 1 },
            { id: 2 }
        ];

        stage.left = 100;
        
        spyOn(stage, "getLeft");

        spyOn(stage.stageGroup, "setLeft");
        spyOn(stage.stageGroup, "setCoords");

        spyOn(stage.dots, "setLeft");
        spyOn(stage.dots, "setCoords");

        spyOn(stage, "manageMovingChildsteps").and.returnValue();

        var _stage = stage;
        var del = true;

        stage.moveIndividualStageAndContents(_stage, del);

        expect(stage.getLeft).toHaveBeenCalled();
        expect(stage.stageGroup.setLeft).toHaveBeenCalledWith(100);
        expect(stage.stageGroup.setCoords).toHaveBeenCalled();

        expect(stage.dots.setLeft).toHaveBeenCalled();
        expect(stage.dots.setCoords).toHaveBeenCalled();
        expect(stage.moveStepAction).toEqual(-1);
        expect(stage.manageMovingChildsteps).toHaveBeenCalledTimes(2);
    });

    it("it should moveIndividualStageAndContents method, when del = false", function() {

        stage.stageGroup = {
            setLeft: function() {},
            setCoords: function() {}
        };

        stage.dots = {
            setLeft: function() {},
            setCoords: function() {}
        };

        stage.childSteps = [
            { id: 1 },
            { id: 2 }
        ];

        stage.left = 100;
        
        spyOn(stage, "getLeft");

        spyOn(stage.stageGroup, "setLeft");
        spyOn(stage.stageGroup, "setCoords");

        spyOn(stage.dots, "setLeft");
        spyOn(stage.dots, "setCoords");

        spyOn(stage, "manageMovingChildsteps").and.returnValue();

        var _stage = stage;
        var del = false;

        stage.moveIndividualStageAndContents(_stage, del);

        expect(stage.getLeft).toHaveBeenCalled();
        expect(stage.stageGroup.setLeft).toHaveBeenCalledWith(100);
        expect(stage.stageGroup.setCoords).toHaveBeenCalled();

        expect(stage.dots.setLeft).toHaveBeenCalled();
        expect(stage.dots.setCoords).toHaveBeenCalled();
        expect(stage.moveStepAction).toEqual(1);
        expect(stage.manageMovingChildsteps).toHaveBeenCalledTimes(2);
    });

    it("It should test manageMovingChildsteps method", function() {

        var childStep = {
            moveStep: function() {},
            circle: {
                moveCircleWithStep: function() {}
            }
        };

        spyOn(childStep, "moveStep");
        spyOn(childStep.circle, "moveCircleWithStep");

        stage.manageMovingChildsteps(childStep);

        expect(childStep.moveStep).toHaveBeenCalled();
        expect(childStep.circle.moveCircleWithStep).toHaveBeenCalled();
    });

    it("It should test moveAllStepsAndStages method", function() {

        var del = true;
        spyOn(stage, "moveIndividualStageAndContents");

        stage.moveAllStepsAndStages(del);

        expect(stage.moveIndividualStageAndContents).toHaveBeenCalled();
    });

    it("It should test updateStageData method", function() {

        var action = -1;
        stage.index = 1;

        spyOn(stage, "stageHeader").and.returnValue(true);

        stage.updateStageData(action);

        expect(stage.stageHeader).toHaveBeenCalled();
        expect(stage.index).toEqual(0);
    });

    it("It should test updateStageData method, and should go into while loop", function() {

        var action = 1;
        stage.index = 1;

        stage.nextStage = {

            index: 2,
            stageHeader: function() {},
        };
        spyOn(stage.nextStage, "stageHeader").and.returnValue(true);

        stage.updateStageData(action);

        expect(stage.nextStage.stageHeader).toHaveBeenCalled();
        expect(stage.nextStage.index).toEqual(3);
    });

    it("It should test squeezeStage method", function() {

        var step = {
            index: 0,
            ordealStatus: 1
        };

        stage.childSteps = [
            {}
        ];

        spyOn(stage, "deleteFromStage").and.returnValue(true);

        stage.squeezeStage(step);

        expect(stage.deleteFromStage).toHaveBeenCalled();
    });

    it("It should test squeezeStage method, when stage has no child steps", function() {

        var step = {
            index: 0,
            ordealStatus: 1,
            parentStage: {
                index: 2
            }
        };

        stage.childSteps = [
            
        ];

        stage.parent = {
            allStageViews: {
                splice: function() {}
            }
        };
        stage.previousStage = {

            childSteps: [
                {
                    parentStage: {
                        updateStageData: function() {}
                    }
                }
            ]
        };

        spyOn(stage, "deleteFromStage").and.returnValue(true);
        spyOn(stage, "wireStageNextAndPrevious").and.returnValue(true);
        spyOn(stage.parent.allStageViews, "splice");
        spyOn(stage.previousStage.childSteps[0].parentStage, "updateStageData");

        stage.squeezeStage(step);

        expect(stage.deleteFromStage).toHaveBeenCalled();
        expect(stage.wireStageNextAndPrevious).toHaveBeenCalled();
        expect(stage.parent.allStageViews.splice).toHaveBeenCalled();
        expect(stage.previousStage.childSteps[0].parentStage.updateStageData).toHaveBeenCalled();
    });

    it("It should test squeezeStage method, when stage has no child steps and no previousStage", function() {

        var step = {
            index: 0,
            ordealStatus: 1,
            parentStage: {
                nextStage: {
                    childSteps: [
                        {
                            parentStage: {
                                updateStageData: function() {}
                            }
                        }
                    ]
                },
                index: 2
            }
        };

        stage.childSteps = [
            
        ];

        stage.parent = {
            allStageViews: {
                splice: function() {}
            }
        };
        stage.nextStage = {

            childSteps: [
                {
                    parentStage: {
                        updateStageData: function() {}
                    }
                }
            ]
        };

        spyOn(stage, "deleteFromStage").and.returnValue(true);
        spyOn(stage, "wireStageNextAndPrevious").and.returnValue(true);
        spyOn(stage.parent.allStageViews, "splice");
        spyOn(step.parentStage.nextStage.childSteps[0].parentStage, "updateStageData");

        stage.squeezeStage(step);

        expect(stage.deleteFromStage).toHaveBeenCalled();
        expect(stage.wireStageNextAndPrevious).toHaveBeenCalled();
        expect(stage.parent.allStageViews.splice).toHaveBeenCalled();
        expect(step.parentStage.nextStage.childSteps[0].parentStage.updateStageData).toHaveBeenCalled();
    });

    it("It should test shortenStageName method", function() {

        stage.stageName = {
            setText: function() {

            },
            text: "0123456789"
        };

        spyOn(stage.stageName, "setText");

        stage.shortenStageName();

        expect(stage.shortStageName).toEqual(true);
        expect(stage.stageName.setText).toHaveBeenCalledWith('01234567');
    });

    describe("Test getLeft method in different scenarios", function() {

        it("It should test getLeft method when stage has no previous stage", function() {

            stage.parentStage = null;

            stage.getLeft();

            expect(stage.left).toEqual(33);
        });

        it("It should test getLeft method when stage has a previous stage", function() {

            stage.previousStage = {
                left: 100,
                myWidth: 200,
            };

            stage.getLeft();
            expect(stage.left).toEqual(308);
        });        
    });

    it("It should test addSteps method", function() {

                stage.model = {
            steps: {
                reduce: function(callback) {
                    var a, b, c;
                    callback.call(stage, a, b, c);
                }
            }
        };
        
        spyOn(stage, "configureStepOnCreate").and.returnValue(true);
        spyOn(stage.model.steps, "reduce").and.callThrough();

        stage.addSteps();

        expect(stage.model.steps.reduce).toHaveBeenCalled();
        expect(stage.configureStepOnCreate).toHaveBeenCalled();
    });
    
    describe("Testing scenarios in configureStepOnCreate", function() {
        
        it("It should test configureStepOnCreate method, when its not insertMode", function() {
        
            stage.insertMode = true;

            var tempStep = {
                name: "I am temporary",
                nextStep: null
            };

            stage.childSteps = [];

            var STEP = {
                step: {

                }
            };

            var stepIndex = 1;

            var retVal = stage.configureStepOnCreate(tempStep, STEP, stepIndex);

            expect(retVal.previousStep.name).toEqual("I am temporary");
            expect(retVal.stepStatus).toEqual("newly created");
            expect(tempStep.nextStep.stepStatus).toEqual("newly created");
            expect(stage.childSteps.length).toEqual(1);
        });

        it("It should test configureStepOnCreate method, when insertMode is false", function() {


        });

    });


    

}); 