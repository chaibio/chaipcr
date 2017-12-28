describe("Testing circleMaker", function() {

    var circleMaker;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
            $provide.value('constants', {
                stepWidth: 128
            });
        });

        inject(function($injector) {
            circleMaker = $injector.get('circleMaker');
        });

    });

    it("It should test circleMaker", function() {

        var left = 10;

        var prop = new circleMaker(left);

        expect(prop.left).toEqual(left);
        expect(prop.radius).toEqual(2);
        expect(prop.fill).toEqual("white");
        expect(prop.name).toEqual("temperatureControllerLittleDude");
        expect(prop.selectable).toEqual(false);
    });

});