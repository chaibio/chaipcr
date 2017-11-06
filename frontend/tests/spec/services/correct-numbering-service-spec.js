describe("Testing correctNumberingService", function() {

    beforeEach(module('ChaiBioTech', function ($provide) {
      mockCommonServices($provide);
    }));

    var _correctNumberingService;
    
    beforeEach(inject(function(correctNumberingService) {
        _correctNumberingService = correctNumberingService;
    }));

    it("It should test initial values", function() {

        expect(_correctNumberingService.canvasObj).toEqual(null);
        expect(_correctNumberingService.oStatus).toEqual(0);
        expect(_correctNumberingService.tempCircle).toEqual(null);
    });

    it("It should test init method", function() {

        var testObj = {
            test: true
        };
        _correctNumberingService.init(testObj);

        expect(_correctNumberingService.canvasObj).toEqual(jasmine.objectContaining({
            test: true
        }));
    });

    it("It should test correctNumbering method", function() {

        _correctNumberingService.canvasObj = {
            allStepViews: [1, 2, 3],
            allStageViews: [
                { index: 1 },
                { index: 2 },
            ]
        };
        
        spyOn(_correctNumberingService, "correctNumberingStage").and.returnValue(true);

        _correctNumberingService.correctNumbering();
        
        expect(_correctNumberingService.oStatus).toEqual(1);
        expect(_correctNumberingService.tempCircle).toEqual(null);
        expect(_correctNumberingService.canvasObj.allStepViews.length).toEqual(0);
        expect(_correctNumberingService.correctNumberingStage).toHaveBeenCalled();
    });

    it("It should test correctNumberingStage method", function() {

        var stage = {
            stageCaption: {
                setText: function() {}
            },
            childSteps: [
                { index: 1 },
                { index: 2 },
            ]
        };

        spyOn(_correctNumberingService, "correctNumberingStep").and.returnValue(true);
        spyOn(stage.stageCaption, "setText");
        _correctNumberingService.correctNumberingStage(stage, 1);

        expect(stage.stageMovedDirection).toEqual(null);
        expect(stage.index).toEqual(1);
        expect(stage.stageCaption.setText).toHaveBeenCalled();
        expect(_correctNumberingService.correctNumberingStep).toHaveBeenCalled();
    });

    it("It should test correctNumberingStep", function() {

        _correctNumberingService.oStatus = 100;

        _correctNumberingService.canvasObj= {
                allStepViews: {
                    push: function() {}
                }
            };


        var step = {
            borderLeft: {
                setVisible: function() {}
            },
            circle: {
                previous: {

                }
            }
        };

        
        spyOn(step.borderLeft, "setVisible");
        spyOn(_correctNumberingService.canvasObj.allStepViews, "push");

        _correctNumberingService.correctNumberingStep(step, 10);

        expect(step.circle.previous).toEqual(null);
        expect(step.index).toEqual(10);
        expect(step.borderLeft.setVisible).toHaveBeenCalledWith(false);
        expect(step.stepMovedDirection).toEqual(null);
        expect(step.nextIsMoving).toEqual(null);
        expect(step.previousIsMoving).toEqual(null);
        expect(step.ordealStatus).toEqual(100);
        expect(_correctNumberingService.canvasObj.allStepViews.push).toHaveBeenCalled();
        expect(_correctNumberingService.oStatus).toEqual(101);

    });

    it("It should test correctNumberingStep when tempCircle has value", function() {

        _correctNumberingService.oStatus = 100;

        _correctNumberingService.tempCircle = {
            next: null,
        };

        _correctNumberingService.canvasObj= {
                allStepViews: {
                    push: function() {}
                }
            };


        var step = {
            borderLeft: {
                setVisible: function() {}
            },
            circle: {
                previous: {

                }
            }
        };

        
        spyOn(step.borderLeft, "setVisible");
        spyOn(_correctNumberingService.canvasObj.allStepViews, "push");

        _correctNumberingService.correctNumberingStep(step, 10);

        //expect(step.circle.previous).toEqual(null);
        expect(_correctNumberingService.tempCircle.next).toEqual(jasmine.any.Object);
        expect(step.index).toEqual(10);
        expect(step.borderLeft.setVisible).toHaveBeenCalledWith(false);
        expect(step.stepMovedDirection).toEqual(null);
        expect(step.nextIsMoving).toEqual(null);
        expect(step.previousIsMoving).toEqual(null);
        expect(step.ordealStatus).toEqual(100);
        expect(_correctNumberingService.canvasObj.allStepViews.push).toHaveBeenCalled();
        expect(_correctNumberingService.oStatus).toEqual(101);

    });
});
