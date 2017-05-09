describe("Testing move-stage", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));
    
    var _moveStageRect, indicator, stage = {}, C, movement = {};
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
    beforeEach(inject(function(moveStageRect) {
        var me = {};
        indicator = moveStageRect.getMoveStageRect(me);
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
        //spyOn(indicator.verticalLine, "setLeft").and.callFake(function() {

        //});
        //spyOn(indicator.kanvas.canvas, "bringToFront");
        indicator.init(stage, C, movement);
        expect(indicator.setCoords).toHaveBeenCalled();
        expect(indicator.setLeft).toHaveBeenCalled();
        expect(indicator.setVisible).toHaveBeenCalled();
        //console.log("stager", stage);
        //expect(indicator.verticalLine.setLeft).toHaveBeenCalled();

    });
    
});