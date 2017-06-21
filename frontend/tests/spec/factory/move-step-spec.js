describe("Testing moveStepRect", function() {
    
    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));
    
    var indicator, step, backupStageModel = {}, C = {}, _StepPositionService, _StagePositionService, footer = {left: 10};
    
    beforeEach(inject(function(moveStepRect, Image, StepPositionService, StagePositionService) {
        
        _StepPositionService = StepPositionService;
        _StagePositionService = StagePositionService;

        var obj = {
            imageobjects: {
                "drag-footer-image.png": Image.create()
            }
        };

        step = {
           previousStep: {

           },
           nextStep: {

           },
           parentStage: {
               stageHeader: function() {},
               adjustHeader: function() {},
               childSteps: [

               ]
           }

        };

        C = {
           canvas: {
               bringToFront: function() {}
           }
        };

        indicator = moveStepRect.getMoveStepRect(obj);
    
    }));

    it("It should test indicator", function() { 
        expect(indicator).toEqual(jasmine.any(Object));
    });

    it("It should test indicator.verticalLine", function() { 
        expect(indicator.verticalLine).toEqual(jasmine.any(Object));
    });

    it("It should test init method", function() {

        spyOn(_StagePositionService, "getPositionObject");
        spyOn(_StagePositionService, "getAllVoidSpaces");
        spyOn(_StepPositionService, "getPositionObject");
        spyOn(indicator, "changeText").and.callFake(function() {
            return true;
        });
        indicator.init(step, footer, C, backupStageModel);

        expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
    });

});