describe("Testing move-stage", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));
    
    var _moveStageRect, indicator, stage = {}, C, movement = {}, _StagePositionService;
    C = {
        canvas: {
            bringToFront: function() {},
        }
    };

    stage = {
        left: 150
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
});