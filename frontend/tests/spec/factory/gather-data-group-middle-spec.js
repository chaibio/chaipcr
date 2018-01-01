describe("Testing gatherDataGroupMiddle ", function() {

    var gatherDataGroupMiddle;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            gatherDataGroupMiddle = $injector.get('gatherDataGroupMiddle');
        });
    });

    it("It should test gatherDataGroupMiddle", function() {

        var objs = [];
        var parent = {
            top: 100,
            left: 200,
            previous: {

            }
        };
        var prop = new gatherDataGroupMiddle(objs, parent);

        expect(prop.left).toEqual(parent.left);
        expect(prop.top).toEqual(parent.top - 20);
        expect(prop.selectable).toEqual(false);
        expect(prop.name).toEqual("gatherDataGroupMiddle");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.visible).toEqual(false);
    });

    it("It should test gatherDataGroupMiddle when parent has no previous", function() {

        var objs = [];
        var parent = {
            top: 100,
            left: 200,
            previous: null
        };
        var prop = new gatherDataGroupMiddle(objs, parent);

        expect(prop.top).toEqual(230);
    });
});