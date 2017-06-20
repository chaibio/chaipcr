describe("Testing moveStepRectangle", function() {
    
    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));
    
    var _moveStepRectangle;
    
    beforeEach(inject(function(moveStepRectangle) {
        _moveStepRectangle = new moveStepRectangle("ME");
    }));

    it("It should test fill property", function() {
        expect(_moveStepRectangle.fill).toEqual("white");
    });

    it("It should test width property", function() {
        expect(_moveStepRectangle.width).toEqual(96);
    });

    it("It should test selectable property", function() {
        expect(_moveStepRectangle.selectable).toEqual(false);
    });

    it("It should test name property", function() {
        expect(_moveStepRectangle.name).toEqual("step");
    });

    it("It should test height property", function() {
        expect(_moveStepRectangle.height).toEqual(72);
    });

    it("It should test left property", function() {
        expect(_moveStepRectangle.left).toEqual(0);
    });

    it("It should test rx property", function() {
        expect(_moveStepRectangle.rx).toEqual(1);
    });

    it("It should test me property", function() {
        expect(_moveStepRectangle.me).toEqual("ME");
    });

});