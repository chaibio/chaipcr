describe("Testing gatherDataCircleOnScroll ", function() {

    var gatherDataCircleOnScroll;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            gatherDataCircleOnScroll = $injector.get('gatherDataCircleOnScroll');
        });
    });

    it("It should test gatherDataCircleOnScroll", function() {

        var prop = new gatherDataCircleOnScroll();

        expect(prop.radius).toEqual(8);
        expect(prop.stroke).toEqual("black");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.fill).toEqual("black");
        expect(prop.selectable).toEqual(false);
        expect(prop.name).toEqual("gatherDataCircleOnScroll");
        
        

    });
});