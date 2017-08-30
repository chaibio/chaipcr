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
            model: {
                hold_time: 0
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
            model: {
                hold_time: 2
            },
            index: 0,
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
        expect(step.deltaSymbol.setVisible).toHaveBeenCalled();
        expect(step.deltaGroup.setVisible).toHaveBeenCalled();
    });


    it("It should test editStageModeStep method when auto_delta == 0", function() {
        
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
            model: {
                hold_time: 2
            },
            index: 1,
            parentStage: {
                model: {
                    auto_delta: 0
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
        expect(step.deltaGroup.setVisible).not.toHaveBeenCalled();
    });

    it("It should test editModeStageChanges method when status is true", function() {

        var stage = {
            childSteps: [
                { index: 1 },
            ],
            shortenStageName: function() {},
            dots: {
                setCoords: function() {},
                setVisible: function() {}
            },
            stageHeader: function() {},
            stageNameGroup: {
                moved: "left",
                left: 100,
                set: function() {},
                setCoords: function() {}
            }
        };

        _editModeService.status = true;

        _editModeService.canvasObj = {
            canvas: {
                bringToFront: function() {}
            }
        };

        spyOn(stage, "shortenStageName");
        spyOn(stage.dots, "setCoords");
        spyOn(stage.dots, "setVisible");
        spyOn(stage, "stageHeader");
        spyOn(stage.stageNameGroup, "set");
        spyOn(stage.stageNameGroup, "setCoords");

        _editModeService.editModeStageChanges(stage);

        expect(stage.dots.setCoords).toHaveBeenCalled();
        expect(stage.dots.setVisible).toHaveBeenCalled();
        expect(stage.stageNameGroup.moved).toEqual("right");
        expect(stage.shortenStageName).toHaveBeenCalled();
        expect(stage.stageHeader).not.toHaveBeenCalled();
    });

    it("It should test editModeStageChanges method when status is true looking at else paths", function() {

        var stage = {
            childSteps: [
                { index: 1 },
                { index: 2 },
                { index: 3 },
            ],
            shortenStageName: function() {},
            dots: {
                setCoords: function() {},
                setVisible: function() {}
            },
            stageHeader: function() {},
            stageNameGroup: {
                moved: "right",
                left: 100,
                set: function() {},
                setCoords: function() {}
            }
        };

        _editModeService.status = true;

        _editModeService.canvasObj = {
            canvas: {
                bringToFront: function() {}
            }
        };

        spyOn(stage, "shortenStageName");
        spyOn(stage.dots, "setCoords");
        spyOn(stage.dots, "setVisible");
        spyOn(stage, "stageHeader");
        spyOn(stage.stageNameGroup, "set");
        spyOn(stage.stageNameGroup, "setCoords");

        _editModeService.editModeStageChanges(stage);

        expect(stage.stageNameGroup.set).not.toHaveBeenCalled();
        expect(stage.stageNameGroup.setCoords).not.toHaveBeenCalled();
        expect(stage.shortenStageName).not.toHaveBeenCalled();
        expect(stage.stageHeader).not.toHaveBeenCalled();
    });

    it("It should test editModeStageChanges method when status is false", function() {

        var stage = {
            childSteps: [
                { index: 1 },
                { index: 2 },
                { index: 3 },
            ],
            shortenStageName: function() {},
            dots: {
                setCoords: function() {},
                setVisible: function() {}
            },
            stageHeader: function() {},
            stageNameGroup: {
                moved: "right",
                left: 100,
                set: function() {},
                setCoords: function() {}
            }
        };

        _editModeService.status = false;

        _editModeService.canvasObj = {
            canvas: {
                bringToFront: function() {}
            }
        };

        spyOn(stage, "shortenStageName");
        spyOn(stage.dots, "setCoords");
        spyOn(stage.dots, "setVisible");
        spyOn(stage, "stageHeader");
        spyOn(stage.stageNameGroup, "set");
        spyOn(stage.stageNameGroup, "setCoords");

        _editModeService.editModeStageChanges(stage);

        expect(stage.stageNameGroup.set).toHaveBeenCalled();
        expect(stage.stageNameGroup.setCoords).toHaveBeenCalled();
        expect(stage.stageNameGroup.moved).toEqual(false);
        expect(stage.stageHeader).toHaveBeenCalled();
    });

    it("It should test editModeStageChanges method when status is false and moved !== right", function() {

        var stage = {
            childSteps: [
                { index: 1 },
                { index: 2 },
                { index: 3 },
            ],
            shortenStageName: function() {},
            dots: {
                setCoords: function() {},
                setVisible: function() {}
            },
            stageHeader: function() {},
            stageNameGroup: {
                moved: "left",
                left: 100,
                set: function() {},
                setCoords: function() {}
            }
        };

        _editModeService.status = false;

        _editModeService.canvasObj = {
            canvas: {
                bringToFront: function() {}
            }
        };

        spyOn(stage, "shortenStageName");
        spyOn(stage.dots, "setCoords");
        spyOn(stage.dots, "setVisible");
        spyOn(stage, "stageHeader");
        spyOn(stage.stageNameGroup, "set");
        spyOn(stage.stageNameGroup, "setCoords");

        _editModeService.editModeStageChanges(stage);

        expect(stage.stageNameGroup.set).not.toHaveBeenCalled();
        expect(stage.stageNameGroup.setCoords).not.toHaveBeenCalled();
        
        expect(stage.stageHeader).toHaveBeenCalled();
    });

    it("It should test temporaryChangeForStatus", function() {

        var stage = {}, tempStat = false;
        _editModeService.status = true;
        spyOn(_editModeService, "editModeStageChanges").and.returnValue(true);
        _editModeService.temporaryChangeForStatus(tempStat, stage);
        expect(_editModeService.editModeStageChanges).toHaveBeenCalled();
        expect(_editModeService.status).toEqual(true);
    });
});