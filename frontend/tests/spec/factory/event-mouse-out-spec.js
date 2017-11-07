describe("Testing mouseOut events", function() {

    var mouseOut, C, $scope, that;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {
            mouseOut = $injector.get('mouseOut');
            
            mouseOut.canvas = {
                on: function() {}
            };

            that = {
                canvas: {
                    hoverCursor: "anything"
                }
            };
            mouseOut.init(C, $scope, that);

            
        });
    });

    it("It should test init method", function() {
        
        spyOn(mouseOut.canvas, "on");
        mouseOut.init(C, $scope, that);
        expect(mouseOut.canvas.on).toHaveBeenCalled();
    });

    describe("It should test mouseOutHandler method in different scenarios", function() {

        it("It should test mouseOutHandler when there is no target", function() {

            var evt = {
                target: null,
            };

            var retVal = mouseOut.mouseOutHandler(evt);

            expect(retVal).toEqual(false);

        });

        it("It should test mouseOutHandler when controlCircleGroup is mouseOut", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "controlCircleGroup"
                }
            };

            mouseOut.mouseOutHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("move");
        });

        it("It should test mouseOutHandler with moveStep is mouseOut", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "moveStep"
                }
            };

            mouseOut.mouseOutHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("move");
        });

        it("It should test mouseOutHandler with moveStage is mouseOut", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "moveStage"
                }
            };

            mouseOut.mouseOutHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("move");
        });

        it("It should test mouseOutHandler with deleteStepButton", function() {

            expect(that.canvas.hoverCursor).toEqual("anything");

            var evt = {
                target: {
                    name: "deleteStepButton"
                }
            };

            mouseOut.mouseOutHandler(evt);

            expect(that.canvas.hoverCursor).toEqual("move");

        });
    });
});