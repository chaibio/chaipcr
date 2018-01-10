describe("Testing gatherDataCircle ", function() {

    var gatherDataCircle;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            gatherDataCircle = $injector.get('gatherDataCircle');
        });
    });

    it("It should test gatherDataCircle", function() {

        var prop = new gatherDataCircle();

        expect(prop.radius).toEqual(13);
        expect(prop.stroke).toEqual("#ffde00");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.fill).toEqual("#ffb400");
        expect(prop.strokeWidth).toEqual(2);
        expect(prop.selectable).toEqual(false);
        expect(prop.name).toEqual("gatherDataCircle");
        
    });
});