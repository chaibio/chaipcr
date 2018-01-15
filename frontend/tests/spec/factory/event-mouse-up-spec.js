describe("Testing mouse up events", function() {

    var mouseUp, that, C, $scope, _circleManager;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            mouseUp = $injector.get('mouseUp');

            _circleManager = $injector.get('circleManager');

            mouseUp.canvas = {
                on: function() {}
            };

            that = {
                mouseDown: true,
                canvas: {
                    defaultCursor: "anything",
                    hoverCursor: "anything", 
                    renderAll: function() {},
                }
            };

            C = {
                moveDots: {
                    setVisible: function() {}
                },
                stageIndicator: {
                    processMovement: function() {},
                },
                stepIndicator: {
                    setVisible: function() {},
                    processMovement: function() {},
                },

                canvas: {
                    renderAll: function() {}
                }
            };

            mouseUp.init(C, $scope, that);

        });
    });
    

    it("It should test init method", function() {

        spyOn(mouseUp.canvas, "on");
        mouseUp.init(C, $scope, that);
        expect(mouseUp.canvas.on).toHaveBeenCalled();
    });

    describe("Testing different conditions in mouseUpHandler method", function() {

        it("It should test when mouseDown is active", function() {

            var evt = {

            };

            spyOn(that.canvas, "renderAll");

            mouseUp.mouseUpHandler(evt);

            expect(that.canvas.defaultCursor).toEqual("default");
            expect(that.startDrag).toEqual(0);
            expect(that.mouseDown).toEqual(false);
            expect(that.canvas.renderAll).toHaveBeenCalled();
        });

        it("It should test when mouseDown is false", function() {

            var evt = {};
            that.mouseDown = false;

            spyOn(that.canvas, "renderAll");

            mouseUp.mouseUpHandler(evt);

            expect(that.canvas.moveCursor).toEqual("move");
            expect(that.canvas.renderAll).not.toHaveBeenCalled();
        });

        it("It should test when moveStepActive is true", function() {
            /*
            var evt = {
                target: {
                    parent: {
                        parentStage: {
                            updateWidth: function() {}
                        }
                    }
                }
            };
            
            that.moveStepActive = true;
            //spyOn(C.moveDots, "setVisible");
            //spyOn(C.stepIndicator, "setVisible");
            //spyOn(evt.target.parent.parentStage, "updateWidth");
            //spyOn(C.stepIndicator, "processMovement");
            //spyOn(C.canvas, "renderAll");
            mouseUp.init(C, $scope, that);

            mouseUp.mouseUpHandler(evt);

            //expect(C.moveDots.setVisible).toHaveBeenCalled(); 
            //that.moveStepActive = false;
            */
        });
        
        it("It should test whne moveStageActive is true", function() {

            var evt = {
                target: {
                    parent: {

                    }
                }
            };

            spyOn(C.stageIndicator, "processMovement");
            spyOn(C.canvas, "renderAll");
            that.moveStageActive = true;

            mouseUp.init(C, $scope, that);

            mouseUp.mouseUpHandler(evt);

            expect(that.moveStageActive).toEqual(false);
            expect(C.stageIndicator.processMovement).toHaveBeenCalled();
            expect(C.canvas.renderAll).toHaveBeenCalled();
        });
    });
});