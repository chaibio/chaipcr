describe("Testing move-stage", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));
    
    var _moveStageRect, indicator, stage = {}, C, movement = {}, _StagePositionService;
    C = {
        canvas: {
            bringToFront: function() {},
            allStageViews: [
                {
                    childSteps: [
                        {
                            step: "first"
                        }
                    ]
                }

            ]
        }
    };

    stage = {
        left: 150,
        moveToSide: function() {

        }
    };

    movement = {
        left: 100
    };

    beforeEach(inject(function(moveStageRect, StagePositionService) {
        var me = {};
        indicator = moveStageRect.getMoveStageRect(me);
        _StagePositionService = StagePositionService;
    }));

    it("It should check if indicator exists", function() {
        expect(indicator).toEqual(jasmine.any(Object));
    });

    it("It should check if indicator exists", function() {
        expect(indicator.verticalLine).toEqual(jasmine.any(Object));
    });

    it("It should check if canvasContaining exists", function() {
        expect(indicator.canvasContaining).toEqual(jasmine.any(Object));
    });

    it("It should check init method, check set values", function() {
        indicator.init(stage, C, movement);
        expect(indicator.rightOffset).toEqual(85);
        expect(indicator.leftOffset).toEqual(-55);
        expect(indicator.currentLeft).toEqual(movement.left);
        expect(indicator.currentMoveRight).toEqual(null);
        expect(indicator.currentMoveLeft).toEqual(null);
        expect(indicator.currentDrop).toEqual(null);
        expect(indicator.direction).toEqual(null);
        expect(indicator.draggedStage).toEqual(stage);
        expect(indicator.currentMoveRight).toEqual(null);
        
    });

    it("it should check init method, function calls ", function() {
        spyOn(indicator, "setLeft");
        spyOn(indicator, "setVisible");
        spyOn(indicator, "setCoords");
        
        indicator.verticalLine = {
            setVisible: function() {},
            setLeft: function() {},
            setCoords: function() {}
        };

        spyOn(indicator.verticalLine, "setLeft");
        spyOn(indicator.verticalLine, "setVisible");
        spyOn(indicator.verticalLine, "setCoords");
        
        spyOn(_StagePositionService, "getPositionObject");
        indicator.init(stage, C, movement);

        expect(indicator.setCoords).toHaveBeenCalled();
        expect(indicator.setLeft).toHaveBeenCalled();
        expect(indicator.setVisible).toHaveBeenCalled();
        
        expect(indicator.verticalLine.setLeft).toHaveBeenCalled();
        expect(indicator.verticalLine.setVisible).toHaveBeenCalled();
        expect(indicator.verticalLine.setCoords).toHaveBeenCalled();
        expect(_StagePositionService.getPositionObject).toHaveBeenCalled();

    });
    
    it("It should check init when a passed stage has previousStage", function() {
        stage.previousStage = "previousStage";
        indicator.init(stage, C, movement);
        expect(indicator.currentDrop).toEqual("previousStage");
    });

    it("It should check changeText method", function() {
        indicator.init(stage, C, movement);
        stage.stageCaption = {
            text: "stageCaption"
        };
        stage.model = {
            stage_type: "Holding"
        };

        indicator.changeText(stage);

        expect(indicator.stageName.text).toEqual("stageCaption");
        expect(indicator.stageType.text).toEqual("HOLDING");

    });

    it("It should check getDirection method, when we move right", function() {
        indicator.init(stage, C, movement);
        movement.left = 110;
        indicator.getDirection();
        expect(indicator.direction).toEqual("right");

    });

    it("It should check getDirection method, when we move left", function() {
        indicator.init(stage, C, movement);
        movement.left = 90;
        indicator.getDirection();
        expect(indicator.direction).toEqual("left");

    });

    it("It should test ifOverRightSideForOneStepStage method, this is invoked when we user drag stage over a single step stage", function() {
        movement = {
            left: 250,
        };
        indicator.init(stage, C, movement);
        _StagePositionService.allPositions = [
            [33, 162, 291]
        ];

        indicator.kanvas.allStageViews = [
                {
                    moveToSide: function() {},
                    childSteps: [
                        {
                            step: "first"
                        }
                    ]

                },
            ];
        spyOn(indicator, "ifOverRightSideForOneStepStageCallback");
        indicator.ifOverRightSideForOneStepStage();
        expect(indicator.ifOverRightSideForOneStepStageCallback).toHaveBeenCalled();
    });

    it("It should test ifOverRightSideForOneStepStageCallback", function() {
    
        movement = {
            left: 250,
        };
        indicator.init(stage, C, movement);
        spyOn(_StagePositionService, "getPositionObject");

        indicator.kanvas.allStageViews = [
                {
                    moveToSide: function() {},
                    childSteps: [
                        {
                            step: "first"
                        }
                    ]

                },
            ];

        spyOn(indicator.kanvas.allStageViews[0], "moveToSide");
        indicator.ifOverRightSideForOneStepStageCallback([33, 162, 291], 0);

        expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
        expect(indicator.kanvas.allStageViews[0].moveToSide).toHaveBeenCalled();
        expect(indicator.currentMoveRight).toEqual(0);
    });

    it("It should test ifOverLeftSideForOneStepStage method", function() {

        movement = {
            left: 100,
        };
        indicator.init(stage, C, movement);
        _StagePositionService.allPositions = [
            [33, 200, 291]
        ];

        indicator.kanvas.allStageViews = [
                {
                    moveToSide: function() {},
                    childSteps: [
                        {
                            step: "first"
                        }
                    ]

                },
            ];
        
        spyOn(indicator, "ifOverLeftSideForOneStepStageCallback");
        indicator.ifOverLeftSideForOneStepStage();
        expect(indicator.ifOverLeftSideForOneStepStageCallback).toHaveBeenCalled();
    });

    it("It should test ifOverLeftSideForOneStepStageCallback method", function() {

        movement = {
            left: 100,
        };
        
        indicator.init(stage, C, movement);

        spyOn(_StagePositionService, "getPositionObject");

        indicator.kanvas.allStageViews = [
                {
                    moveToSide: function() {},
                    childSteps: [
                        {
                            step: "first"
                        }
                    ]

                },
            ];

        spyOn(indicator.kanvas.allStageViews[0], "moveToSide");
        indicator.ifOverLeftSideForOneStepStageCallback([33, 200, 291], 0);

        expect(_StagePositionService.getPositionObject).toHaveBeenCalled();
        expect(indicator.kanvas.allStageViews[0].moveToSide).toHaveBeenCalled();
        expect(indicator.movedStageIndex).toEqual(0);
    });
    
});

