describe("Testing gatherDataGroup ", function() {

    var gatherDataGroup;

    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            gatherDataGroup = $injector.get('gatherDataGroup');
        });
    });

    it("It should test gatherDataGroup", function() {

        var objs = [];
        var parent = {
            left: 300,
            top: 200,
            previous: {
                top: 100
            }
        };

        var prop = new gatherDataGroup(objs, parent);

        expect(prop.left).toEqual(parent.left);
        expect(prop.top).toEqual((parent.top + parent.previous.top) / 2);
        expect(prop.selectable).toEqual(false);
        expect(prop.name).toEqual("gatherDataGroup");
        expect(prop.originX).toEqual("center");
        expect(prop.originY).toEqual("center");
        expect(prop.visible).toEqual(false);
    });

    it("It should test gatherDataGroup when previous is not there", function() {

        var objs = [];
        var parent = {
            left: 300,
            top: 200,
            
        };

        var prop = new gatherDataGroup(objs, parent);

        expect(prop.top).toEqual(230);
    });
});