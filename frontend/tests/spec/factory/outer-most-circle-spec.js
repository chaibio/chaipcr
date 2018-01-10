describe("Testing outerMostCircle", function() {

    var outerMostCircle;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
            $provide.value('constants', {
                stepWidth: 128
            });
        });

        inject(function($injector) {
            outerMostCircle = $injector.get('outerMostCircle');
        });

    });

    it("It should test outerMostCircle", function() {

        var prop = new outerMostCircle({}, {});

        expect(prop.width).toEqual(62);
        expect(prop.height).toEqual(40);
        expect(prop.fill).toEqual("#ffb400");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.selectable).toEqual(false);
        expect(prop.visible).toEqual(false);
        expect(prop.name).toEqual("temperatureControllerOuterMostCircle");
    });

});