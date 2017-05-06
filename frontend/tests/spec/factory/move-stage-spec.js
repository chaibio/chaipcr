describe("Testing move-stage", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));
    
    var _moveStageRect, indicator;

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

    
});