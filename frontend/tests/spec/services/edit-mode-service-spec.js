describe("Testing editModeService", function() {

    beforeEach(module('ChaiBioTech'));

    var _editModeService;

    beforeEach(inject(function(editModeService) {
        _editModeService = editModeService;
    }));

    it("It should test initial values", function() {

        expect(_editModeService.canvasObj).toEqual(null);
        expect(_editModeService.status).toEqual(null);
    });
});