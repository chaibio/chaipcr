describe("Testing editModeService", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));

    var _editModeService, _previouslySelected;

    beforeEach(inject(function(editModeService, previouslySelected) {
        _editModeService = editModeService;
        _previouslySelected = previouslySelected;
    }));

    it("It should test initial values", function() {

        expect(_editModeService.canvasObj).toEqual(null);
        expect(_editModeService.status).toEqual(null);
    });

    it("It should check init method", function() {

        var obj = {
            value: "Checking"
        };

        _editModeService.init(obj);
        
        expect(_editModeService.canvasObj).toEqual(jasmine.objectContaining({
            value: "Checking"
        }));

    });

    it("It should test editStageMode method when status is true", function() {

        _previouslySelected.circle = {
                parent: {
                    manageFooter: function() {},
                    parentStage: {
                        changeFillsAndStrokes: function() {}
                    }
                }
        };

        _editModeService.canvasObj = {
            allStageViews:  [
                { index: 0 },
                { index: 1 },
                { index: 2 }
            ],
            editStageStatus: false,
            canvas: {
                renderAll: function() {}
            }
        };

        spyOn(_editModeService, "editStageModeStage").and.returnValue(true);
        spyOn(_previouslySelected.circle.parent, "manageFooter");
        spyOn(_previouslySelected.circle.parent.parentStage, "changeFillsAndStrokes");
        spyOn(_editModeService.canvasObj.canvas, "renderAll");
        var status = true;
        _editModeService.editStageMode(status);

        expect(_editModeService.canvasObj.editStageStatus).toEqual(status);
        expect(_previouslySelected.circle.parent.manageFooter).toHaveBeenCalledWith("black");
        expect(_previouslySelected.circle.parent.parentStage.changeFillsAndStrokes).toHaveBeenCalledWith("black", 4);
        expect(_editModeService.editStageModeStage).toHaveBeenCalled();
        expect(_editModeService.canvasObj.canvas.renderAll).toHaveBeenCalled();
    });

    it("It should test editStageMode method when status is false", function() {

        _previouslySelected.circle = {
                parent: {
                    manageFooter: function() {},
                    parentStage: {
                        changeFillsAndStrokes: function() {}
                    }
                }
        };

        _editModeService.canvasObj = {
            allStageViews:  [
                { index: 0 },
                { index: 1 },
                { index: 2 }
            ],
            editStageStatus: false,
            canvas: {
                renderAll: function() {}
            }
        };

        spyOn(_editModeService, "editStageModeStage").and.returnValue(true);
        spyOn(_previouslySelected.circle.parent, "manageFooter");
        spyOn(_previouslySelected.circle.parent.parentStage, "changeFillsAndStrokes");
        spyOn(_editModeService.canvasObj.canvas, "renderAll");
        var status = false;
        _editModeService.editStageMode(status);

        expect(_editModeService.canvasObj.editStageStatus).toEqual(status);
        expect(_previouslySelected.circle.parent.manageFooter).toHaveBeenCalledWith("white");
        expect(_previouslySelected.circle.parent.parentStage.changeFillsAndStrokes).toHaveBeenCalledWith("white", 2);
        expect(_editModeService.editStageModeStage).toHaveBeenCalled();
        expect(_editModeService.canvasObj.canvas.renderAll).toHaveBeenCalled();
    });

    it("It should test editStageModeStage method", function() {

       var stage = {
            childSteps: [
                {
                    index: 0,
                    circle: {
                        model: {
                            hold_time: 1
                        }
                    }
                }
            ]
       };

       spyOn(_editModeService, "editStageModeStep").and.returnValue();
       spyOn(_editModeService, "editModeStageChanges").and.returnValue();

       _editModeService.editStageModeStage(stage, 0, 0);

       expect(_editModeService.editModeStageChanges).toHaveBeenCalled();
       expect(_editModeService.editStageModeStep).toHaveBeenCalled();
    });

    it("It should test editStageModeStage method when count and stageIndex differ", function() {

       var stage = {
            childSteps: [
                {
                    index: 0,
                    circle: {
                        model: {
                            hold_time: 1
                        }
                    }
                }
            ]
       };

       spyOn(_editModeService, "editStageModeStep").and.returnValue();
       spyOn(_editModeService, "editModeStageChanges").and.returnValue();

       _editModeService.editStageModeStage(stage, 0, 1);

       expect(_editModeService.editModeStageChanges).toHaveBeenCalled();
       expect(_editModeService.editStageModeStep).toHaveBeenCalled();
    });

    it("It should test editStageModeStep method", function() {
        
        step = {
            deltaGroup: {
                setVisible: function() {}
            },
            deltaSymbol: {
                setVisible: function() {}
            },
            closeImage: {
                setOpacity: function() {}
            },
            dots: {
                setVisible: function() {},
                setCoords: function() {}
            },
            index: 1,
            parentStage: {
                model: {
                    auto_delta: 1
                }
            }
        };

        spyOn(step.closeImage, "setOpacity");
        spyOn(step.dots, "setVisible");
        spyOn(step.dots, "setCoords");
        spyOn(step.deltaSymbol, "setVisible");
        spyOn(step.deltaGroup, "setVisible");

        _editModeService.editStageModeStep(step);

        expect(step.closeImage.setOpacity).toHaveBeenCalled();
        expect(step.dots.setVisible).toHaveBeenCalled();
        expect(step.dots.setCoords).toHaveBeenCalled();
        expect(step.deltaSymbol.setVisible).not.toHaveBeenCalled();
        expect(step.deltaGroup.setVisible).toHaveBeenCalled();
    });
});