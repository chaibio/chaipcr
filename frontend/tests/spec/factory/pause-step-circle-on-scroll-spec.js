describe("Testing pauseStepCircleOnScroll ", function() {

    var pauseStepCircleOnScroll;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            pauseStepCircleOnScroll = $injector.get('pauseStepCircleOnScroll');
        });
    });

    it("It should test pauseStepCircleOnScroll", function() {
        
        var prop = new pauseStepCircleOnScroll();

        expect(prop.radius).toEqual(8);
        expect(prop.stroke).toEqual("#ffde00");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.strokeWidth).toEqual(3);
        expect(prop.fill).toEqual("#ffb400");
        expect(prop.selectable).toEqual(false);
        expect(prop.name).toEqual("pauseDataCircleOnScroll");
    });
});