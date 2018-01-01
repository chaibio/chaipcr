describe("Testing circleGroup", function() {

    var _Group, constants, centerCircle;
    beforeEach(function() {

        module('ChaiBioTech', function($provide) {

            $provide.value('IsTouchScreen', function () {});
            $provide.value('constants', {
                stepWidth: 128
            });
        });

        inject(function($injector) {
            _Group = $injector.get('Group');
            circleGroup = $injector.get('circleGroup');
        });

    });

    it("It should test circleGroup", function() {

        var parent = {
            left: 100,
            top: 100,
        };

        var $scope = {
            exp_completed: false
        };

        var prop = new circleGroup({}, parent, $scope);
        
        expect(prop.left).toEqual(164);
        expect(prop.top).toEqual(100);
        expect(prop.selectable).toEqual(true);
        expect(prop.name).toEqual("controlCircleGroup");
        expect(prop.lockMovementX).toEqual(true);
        expect(prop.evented).toEqual(true);
        expect(prop.hasControls).toEqual(false);
        expect(prop.hasBorders).toEqual(false); 
        expect(prop.originX).toEqual("center"); 
        expect(prop.originY).toEqual("center"); 
    });
});