describe("Testing functionalities of step", function() {

    beforeEach(module('ChaiBioTech'));
    beforeEach(module('canvasApp'));

    var _step;

    beforeEach(inject(function(step) {
        _step = step;
    }));


    it("should test step", function() {
        expect("a").toEqual("a");
    });
});