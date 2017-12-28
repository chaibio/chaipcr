describe("Testing littleCircleGroup", function() {

    var littleCircleGroup;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
            $provide.value('constants', {
                stepWidth: 128
            });
        });

        inject(function($injector) {
            littleCircleGroup = $injector.get('littleCircleGroup');
        });

    });

    it("It should test littleCircleGroup", function() {

        var prop = new littleCircleGroup({}, {});

        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.top).toEqual(0);
        expect(prop.visible).toEqual(false);
        expect(prop.selectable).toEqual(false);
    });

});