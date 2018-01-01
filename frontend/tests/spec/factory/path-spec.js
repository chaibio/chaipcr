describe("Testing path ", function() {

    var curve, path;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {
            $provide.value('IsTouchScreen', function () {});
            $provide.value('constants', {
                stepWidth: 128,
                controlDistance: 4,
            });
        });

        inject(function($injector) {


            path = $injector.get('path');

            var circle = {

                left: 100,
                top: 70,
                next: {
                    left: 200,
                    top: 100,
                }
            };
            curve = new path(circle);
        });
    });

    it("It should chack the curve object", function() {

        expect(curve).toEqual(jasmine.any(Object));
    });

    it("It should test nextOne method", function() {

        
        curve.nextOne(200, 100);
        
        expect(curve.path[0][1]).toEqual(200);
        expect(curve.path[0][2]).toEqual(100);

        expect(curve.path[1][1]).toEqual(204);
        expect(curve.path[1][2]).toEqual(100);

        expect(curve.path[1][3]).toEqual(232);
        expect(curve.path[1][4]).toEqual(100);

        expect(curve.path[2][1]).toEqual(260);
        expect(curve.path[2][2]).toEqual(100);

    });

    it("It should test previousOne method", function() {

        
        curve.previousOne(200, 100);
        
        expect(curve.path[2][3]).toEqual(200);
        expect(curve.path[2][4]).toEqual(100);

        expect(curve.path[2][1]).toEqual(196);
        expect(curve.path[2][2]).toEqual(100);

        expect(curve.path[1][3]).toEqual(182);
        expect(curve.path[1][4]).toEqual(85);

        expect(curve.path[1][1]).toEqual(168);
        expect(curve.path[1][2]).toEqual(70);

    });
});