describe("Testing mouseOver events", function() {

    var mouseOver, C = {}, $scope = {}, that = {};

    beforeEach(function() {
        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            mouseOver = $injector.get('mouseOver');
            
            mouseOver.canvas = {
                on: function() {}
            };

            that = {
                canvas: {
                    hoverCursor: "anything"
                }
            };

            mouseOver.init(C, $scope, that);

        });

    });

    it("It should test init method", function() {

        spyOn(mouseOver.canvas,"on");

        mouseOver.init(C, $scope, that);

        expect(mouseOver.canvas.on).toHaveBeenCalled();
    });

    describe("It should test mouseOverHandler method, in different conditions", function() {

        it("It should test mouseOverHandler method when no target", function() {

            var evt = {
                target: null
            };

            var retVal = mouseOver.mouseOverHandler(evt);

            expect(retVal).toEqual(false);
        });

        it("It should test mouseOverHandler method when target is stepGroup", function() {

            var evt = {
                target: {
                    name: "stepGroup"
                }
            };

            spyOn(mouseOver, "stepGroupHoverHandler").and.returnValue(true);

            mouseOver.mouseOverHandler(evt);

            expect(mouseOver.stepGroupHoverHandler).toHaveBeenCalled();

        });

        it("It should test controlCircleGroup case", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "controlCircleGroup"
                }
            };

            mouseOver.mouseOverHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("pointer");
        });

        

    });

});