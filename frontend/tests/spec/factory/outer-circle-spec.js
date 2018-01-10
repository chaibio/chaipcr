describe("Testing outerCircle", function() {

    var outerCircle;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
            $provide.value('constants', {
                stepWidth: 128
            });
        });

        inject(function($injector) {
            outerCircle = $injector.get('outerCircle');
        });

    });

    it("It should test outerCircle", function() {

        var prop = new outerCircle({}, {});

        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.radius).toEqual(18);
        expect(prop.selectable).toEqual(false);
        expect(prop.hasBorders).toEqual(false);
        expect(prop.fill).toEqual("#ffb400");
        expect(prop.name).toEqual("temperatureControllerOuterCircle");
    });

});