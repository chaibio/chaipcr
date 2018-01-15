describe("Testing pauseStepOnScrollGroup ", function() {

    var pauseStepOnScrollGroup;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            pauseStepOnScrollGroup = $injector.get('pauseStepOnScrollGroup');
        });
    });

    it("It should test pauseStepOnScrollGroup", function() {

        var objs = [];
        
        var prop = new pauseStepOnScrollGroup(objs);

        expect(prop.left).toEqual(20);
        expect(prop.top).toEqual(-18);
        expect(prop.selectable).toEqual(false);
        expect(prop.name).toEqual("pauseStepOnScrollGroup");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.visible).toEqual(false);
    });
});