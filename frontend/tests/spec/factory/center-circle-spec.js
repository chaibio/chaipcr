describe("Testing centerCircle", function() {

    var _Circle, centerCircle;
    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});

        });

        inject(function($injector) {
            _Circle = $injector.get('Circle');
            centerCircle = $injector.get('centerCircle');
        });

    });

    it("It should test centerCircle", function() {

        var prop = new centerCircle();
        expect(prop.radius).toEqual(11);
        expect(prop.stroke).toEqual("white");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.fill).toEqual("#ffb400");
        expect(prop.strokeWidth).toEqual(8);
        expect(prop.selectable).toEqual(false);
        expect(prop.name).toEqual("temperatureControllers");
    });
});