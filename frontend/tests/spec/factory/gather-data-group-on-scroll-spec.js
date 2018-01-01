describe("Testing gatherDataGroupOnScroll ", function() {

    var gatherDataGroupOnScroll;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            gatherDataGroupOnScroll = $injector.get('gatherDataGroupOnScroll');
        });
    });

    it("It should test gatherDataGroupOnScroll", function() {

        var objs = [];
        
        var prop = new gatherDataGroupOnScroll(objs);

        expect(prop.left).toEqual(20);
        expect(prop.top).toEqual(-18);
        expect(prop.selectable).toEqual(false);
        expect(prop.name).toEqual("gatherDataGroupOnScroll");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.visible).toEqual(false);
    });
});